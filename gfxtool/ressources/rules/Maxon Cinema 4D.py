import os
import subprocess
import sys
import shutil
import time
import re
from pathlib import Path

# --- CHEMINS ---

BASE_DIR = Path(__file__).parent.parent.parent  # gfx_tool
RESSOURCES_DIR = BASE_DIR / "ressources"
BUILD_DIR = RESSOURCES_DIR / "output"
INSTALLERS_DIR = BASE_DIR / "installers"

SPEC_SOURCE = BASE_DIR / "autopatcher.spec"
SPEC_DEST = BUILD_DIR / "autopatcher.spec"

AUTOPATCHER_SCRIPT = BUILD_DIR / "autopatcher.py"
INNO_SCRIPT = BUILD_DIR / "build.iss"
PYINSTALLER_OUTPUT = BUILD_DIR

MAXON_SERVICE_EXE = RESSOURCES_DIR / "files" / "Maxon" / "Red Giant Service.exe"
LICENSETYPE_PRF = RESSOURCES_DIR / "files" / "Maxon" / "licensetype.prf"

# --- PATCHER À INJECTER ---

PATCHER_CODE = r'''
import os

def patch_plugins():
    signature = bytes.fromhex("C74058DCFFFFFF33C0EB6D448B4C24684533C0488B542448488B4C2440")
    patch_bytes = bytes.fromhex("B800000000")
    end_pattern = bytes.fromhex("894424")

    targets = [
        r"C:\Program Files\Maxon Cinema 4D 2025\corelibs\c4d_base.xdl64"
    ]

    for binary_path in targets:
        if not os.path.exists(binary_path):
            continue
        try:
            with open(binary_path, "rb") as f:
                data = f.read()
            start = data.find(signature)
            if start == -1:
                continue
            search_from = start + len(signature)
            end = data.find(end_pattern, search_from)
            if end == -1:
                continue
            patched_data = data[:search_from] + patch_bytes + data[end:]
            with open(binary_path, "wb") as f:
                f.write(patched_data)
        except Exception:
            continue

def create_licensetype_prf():
    import pathlib

    # Dossier cible, on cherche le dossier Maxon Cinema 4D 2025* dans %APPDATA%\Maxon
    appdata = os.getenv("APPDATA")
    if not appdata:
        return

    base_dir = os.path.join(appdata, "Maxon")
    if not os.path.isdir(base_dir):
        return

    # Cherche dossier "Maxon Cinema 4D 2025*" dans base_dir
    target_dir = None
    for name in os.listdir(base_dir):
        if name.startswith("Maxon Cinema 4D 2025"):
            target_dir = os.path.join(base_dir, name)
            break
    if not target_dir or not os.path.isdir(target_dir):
        return

    file_path = os.path.join(target_dir, "licensetype.prf")

    # Contenu binaire à écrire
    data_hex = (
        "FF4D41584F4E1F6E65742E6D61786F6E2E66696C6569642E6C6963656E7365747970652E7632760102FF000675696E743332000004000000"
    )
    data_bytes = bytes.fromhex(data_hex)

    try:
        with open(file_path, "wb") as f:
            f.write(data_bytes)
    except Exception:
        pass

if __name__ == "__main__":
    patch_plugins()
    create_licensetype_prf()
'''

# --- UTILS ---

def run_command_silent(cmd):
    CREATE_NO_WINDOW = 0x08000000
    proc = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, creationflags=CREATE_NO_WINDOW
    )
    return proc.returncode, proc.stdout, proc.stderr

def safe_rmtree(path, retries=5, delay=1):
    for i in range(retries):
        try:
            if path.exists():
                shutil.rmtree(path)
            return True
        except PermissionError as e:
            print(f"[!] PermissionError: {e}, tentative {i+1}/{retries}, nouvel essai dans {delay}s...")
            time.sleep(delay)
    print(f"[!] Impossible de supprimer {path} après {retries} tentatives.")
    return False

def extract_version(filename):
    match = re.search(r'(\d+\.\d+\.\d+)', filename)
    return match.group(1) if match else "0.0.0"

# --- MAIN ---

def main():
    if len(sys.argv) < 3:
        print('[!] Usage : python Maxon Cinema 4D.py chemin\\vers\\RedGiant.exe chemin\\vers\\MaxonApp.exe')
        sys.exit(1)

    cinema4d_installer = Path(sys.argv[1])
    maxonapp_installer = Path(sys.argv[2])
    for f in [cinema4d_installer, maxonapp_installer]:
        if not f.exists():
            print(f"[!] {f} introuvable")
            sys.exit(1)

    cinema4d_version = extract_version(cinema4d_installer.name)
    maxon_version = extract_version(maxonapp_installer.name)
    app_name = "Maxon Cinema 4D"
    output_name = f"{app_name} v{cinema4d_version}"

    if not safe_rmtree(BUILD_DIR):
        sys.exit(1)

    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    INSTALLERS_DIR.mkdir(parents=True, exist_ok=True)

    AUTOPATCHER_SCRIPT.write_text(PATCHER_CODE, encoding="utf-8")

    print("[+] Compilation autopatcher avec PyInstaller...")
    ret, out, err = run_command_silent([
        "pyinstaller",
        "--onefile",
        "--noconsole",
        "--distpath", str(PYINSTALLER_OUTPUT),
        "--specpath", str(PYINSTALLER_OUTPUT),
        "--workpath", str(PYINSTALLER_OUTPUT / "build"),
        str(AUTOPATCHER_SCRIPT),
    ])
    if ret != 0:
        print(f"[!] Erreur PyInstaller : {err}")
        sys.exit(1)

    autopatcher_exe = PYINSTALLER_OUTPUT / "autopatcher.exe"
    if not autopatcher_exe.exists():
        print(f"[!] autopatcher.exe introuvable.")
        sys.exit(1)

    # Ici on génère le script Inno Setup
    iss_code = f"""[Setup]
AppName={app_name}
AppVersion={cinema4d_version}
DefaultDirName={{pf}}\\{app_name}
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no
OutputBaseFilename={output_name}
Compression=lzma
SolidCompression=yes
DisableReadyPage=yes
DisableFinishedPage=yes
SetupIconFile="{str(Path(__file__).parent.parent / 'logo.ico')}"

[Files]
Source: "{str(cinema4d_installer)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(maxonapp_installer)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(autopatcher_exe)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(MAXON_SERVICE_EXE)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(LICENSETYPE_PRF)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall

[Code]
var
  MadeByButton: TNewButton;
  InfoPage: TWizardPage;
  PluginsMemo: TNewMemo;
  MaxonInstallerName: string;
  ResultCode: Integer;

procedure OpenLink(Sender: TObject);
begin
  Exec('cmd.exe', '/C start "" https://rentry.co/graphicx-links', '', SW_HIDE, ewNoWait, ResultCode);
end;

procedure InitializeWizard;
begin
  WizardForm.Position := poScreenCenter;

  MadeByButton := TNewButton.Create(WizardForm);
  MadeByButton.Parent := WizardForm;
  MadeByButton.Caption := 'GFX Tool By GRAPHICX';
  MadeByButton.Left := ScaleX(10);
  MadeByButton.Top := WizardForm.ClientHeight - ScaleY(35);
  MadeByButton.Width := ScaleX(200);
  MadeByButton.Height := ScaleY(25);
  MadeByButton.OnClick := @OpenLink;

  InfoPage := CreateCustomPage(wpSelectDir, 'Informations sur les plugins', 'Plugins installés :');

  PluginsMemo := TNewMemo.Create(WizardForm);
  PluginsMemo.Parent := InfoPage.Surface;
  PluginsMemo.Left := ScaleX(10);
  PluginsMemo.Top := ScaleY(0);
  PluginsMemo.Width := InfoPage.SurfaceWidth - ScaleX(20);
  PluginsMemo.Height := ScaleY(200);
  PluginsMemo.ScrollBars := ssVertical;
  PluginsMemo.ReadOnly := True;
  PluginsMemo.Lines.Text :=
    '- Cinema 4D';
end;

procedure KillProcess(const ProcessName: string);
begin
  Exec('taskkill', '/F /IM "' + ProcessName + '" /T', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

function IsProcessRunning(const ExeName: string): Boolean;
begin
  Exec('cmd.exe', '/C tasklist | find /I "' + ExeName + '" > nul', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := ResultCode = 0;
end;

procedure KillMaxonInstallerName;
begin
  if MaxonInstallerName <> '' then
    KillProcess(ExtractFileName(MaxonInstallerName));
end;

procedure MaxonCloseAll;
begin
  while True do
  begin
    if IsProcessRunning('Maxon.exe') then
    begin
      KillProcess('Maxon.exe');
      KillMaxonInstallerName;
      KillProcess('mx1.exe');
      Exit;
    end;
    Sleep(1000);
  end;
end;

procedure C4DCloseAll;
begin
  while True do
  begin
    if IsProcessRunning('Cinema 4D.exe') then
    begin
      KillProcess('Maxon.exe');
      KillProcess('RGContentService.exe');
      KillProcess('MxNotify.exe');
      KillProcess('Cinema 4D Team Render Client.exe');
      KillProcess('Commandline.exe');
      KillProcess('Cinema 4D Team Render Server.exe');
      KillProcess('Cinema 4D.exe');
      Exit;
    end;
    Sleep(1000);
  end;
end;

procedure DeleteOldC4D;
var
  FindRec: TFindRec;
  FullPath: string;
begin
  if FindFirst(ExpandConstant('{{userappdata}}\\Maxon\\Maxon Cinema 4D 2025*'), FindRec) then
  begin
    repeat
      FullPath := ExpandConstant('{{userappdata}}\\Maxon\\') + FindRec.Name;
      if DirExists(FullPath) then
        DelTree(FullPath, True, True, True);
    until not FindNext(FindRec);
    FindClose(FindRec);
    
    FullPath := ExpandConstant('{{pf}}\\Maxon Cinema 4D 2025');
    if DirExists(FullPath) then
      DelTree(FullPath, True, True, True);
  end;
end;

procedure MaxonInstall;
begin
  MaxonInstallerName := ExpandConstant('{{tmp}}\\{maxonapp_installer.name}');
  if not FileExists('C:\\Program Files\\Maxon\\App Manager\\Maxon.exe') then
  begin
    WizardForm.StatusLabel.Caption := 'Installation de Maxon...';
    KillProcess('Red Giant Service.exe');
    KillProcess('mx1.exe');
    KillProcess('Maxon.exe');
    ExtractTemporaryFile(ExtractFileName(MaxonInstallerName));
    Exec(MaxonInstallerName, '', '', SW_HIDE, ewNoWait, ResultCode);
    MaxonCloseAll;
  end
  else
  begin
    if IsProcessRunning('Maxon.exe') then
    begin
      MaxonCloseAll;
    end;
  end;
end;

procedure Cinema4DInstall;
begin
  WizardForm.StatusLabel.Caption := 'Installation de Cinema 4D...';
  Exec(ExpandConstant('{{tmp}}\\{cinema4d_installer.name}'), '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
end;

procedure C4DLicense;
var
  WaitTimeout: Integer;
  FindRec: TFindRec;
  TargetDir, TargetFile: string;
begin
  WaitTimeout := 0;
  while not FindFirst(ExpandConstant('{{userappdata}}\\Maxon\\Maxon Cinema 4D 2025*'), FindRec) do
  begin
    Sleep(1000);
    Inc(WaitTimeout);
    if WaitTimeout > 30 then Exit;
  end;

  TargetDir := ExpandConstant('{{userappdata}}\\Maxon\\') + FindRec.Name;
  TargetFile := TargetDir + '\\licensetype.prf';

  ExtractTemporaryFile('licensetype.prf');
  FileCopy(ExpandConstant('{{tmp}}\\licensetype.prf'), TargetFile, False);

  FindClose(FindRec);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LicFilePath, DestLicPath: string;
begin
  if CurStep = ssInstall then
    MaxonInstall;

  if CurStep = ssPostInstall then
  begin
    DeleteOldC4D;
    Cinema4DInstall;
    C4DCloseAll;
    WizardForm.StatusLabel.Caption := 'Cracking...';
    C4DLicense;
    KillProcess('Maxon.exe');
    KillProcess('RGContentService.exe');
    KillProcess('MxNotify.exe');
    KillProcess('Cinema 4D Team Render Client.exe');
    KillProcess('Commandline.exe');
    KillProcess('Cinema 4D Team Render Server.exe');
    KillProcess('Cinema 4D.exe');
    KillProcess('mx1.exe');
    KillProcess('Red Giant Service.exe');
    Exec('C:\\WINDOWS\\system32\\net1.exe', 'stop "Red Giant Service"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('C:\\WINDOWS\\system32\\net1.exe', 'stop "mxredirect"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('C:\\WINDOWS\\system32\\net1.exe', 'stop "RLM-Redshift"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    LicFilePath := ExpandConstant('{{tmp}}\\GRAPHICX.lic');
    DestLicPath := 'C:\\ProgramData\\Maxon\\RLM\\GRAPHICX.lic';

    if not DirExists('C:\\ProgramData\\Maxon\\RLM') then
      ForceDirectories('C:\\ProgramData\\Maxon\\RLM');

    SaveStringToFile(
      LicFilePath,
      'LICENSE redshift redgiant 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift universesuite 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift cinema4d-release~commercial 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift cinema4d-release~commandline 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift cineware-core~commercial 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift teamrender-release~commercial 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift teamrender-release~commandline 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10 +
      'LICENSE redshift alfred 9999.12 permanent uncounted hostid=ANY sig="60PG453K6XQKRBWSYTTE01PFM9D55604532G9QG22M08G45HEJX00HPA66JP366XMWYXDKXNNP4G"' + #13#10,
      False);
                  
    CopyFile(ExpandConstant('{{tmp}}\\Red Giant Service.exe'), 'C:\\Program Files\\Red Giant\\Services\\Red Giant Service.exe', False);

    Exec('cmd.exe', '/C copy /Y "' + LicFilePath + '" "' + DestLicPath + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    ShellExec('', 'C:\\Program Files\\Maxon\\App Manager\\rgdeploy.exe', '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('C:\\WINDOWS\\system32\\net.exe', 'start "Red Giant Service"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec(ExpandConstant('{{tmp}}\\{autopatcher_exe.name}'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
"""

    INNO_SCRIPT.write_text(iss_code.strip(), encoding="utf-8")

    print("[+] Compilation Inno Setup...")
    ret, out, err = run_command_silent([r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe", str(INNO_SCRIPT)])
    if ret != 0:
        print(f"[!] Erreur Inno Setup : {err}")
        sys.exit(1)

    final_exe = BUILD_DIR / "Output" / f"{output_name}.exe"
    final_dest = INSTALLERS_DIR / f"{output_name}.exe"
    if final_exe.exists():
        final_exe.replace(final_dest)
        print(f"[+] Compilation réussie : {final_dest}")
    else:
        print("[!] Fichier compilé introuvable.")

if __name__ == "__main__":
    main()