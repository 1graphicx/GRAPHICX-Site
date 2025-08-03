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

TOPAZ_BAK = RESSOURCES_DIR / "files" / "Topaz" / "Topaz Video Enhance AI" / "Topaz Video Enhance AI.exe.BAK"
VERSION_DLL = RESSOURCES_DIR / "files" / "Topaz" / "Topaz Video Enhance AI" / "version.dll"

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
    if len(sys.argv) < 2:
        print('[!] Usage : python build_installer.py chemin\\vers\\TopazInstaller.msi')
        sys.exit(1)

    topaz_installer = Path(sys.argv[1])
    if not topaz_installer.exists():
        print(f"[!] {topaz_installer} introuvable")
        sys.exit(1)

    topaz_version = extract_version(topaz_installer.name)
    app_name = "Topaz Video Enhance AI"
    output_name = f"{app_name} v{topaz_version}"

    if not safe_rmtree(BUILD_DIR):
        sys.exit(1)

    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    INSTALLERS_DIR.mkdir(parents=True, exist_ok=True)

    iss_code = f"""[Setup]
AppName={app_name}
AppVersion={topaz_version}
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
Source: "{str(topaz_installer)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TOPAZ_BAK)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(VERSION_DLL)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall

[Code]
function RegDeleteKeyW(hKey: Integer; lpSubKey: string): Integer;
  external 'RegDeleteKeyW@advapi32.dll stdcall';

var
  MadeByButton: TNewButton;
  InfoPage: TWizardPage;
  PluginsMemo: TNewMemo;
  ResultCode: Integer;

procedure OpenLink(Sender: TObject);
begin
  Exec('cmd.exe', '/C start "" https://graphicx.store/', '', SW_HIDE, ewNoWait, ResultCode);
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

  InfoPage := CreateCustomPage(wpSelectDir, 'Informations sur les logiciels', 'Logiciels installés :');

  PluginsMemo := TNewMemo.Create(WizardForm);
  PluginsMemo.Parent := InfoPage.Surface;
  PluginsMemo.Left := ScaleX(10);
  PluginsMemo.Top := ScaleY(0);
  PluginsMemo.Width := InfoPage.SurfaceWidth - ScaleX(20);
  PluginsMemo.Height := ScaleY(200);
  PluginsMemo.ScrollBars := ssVertical;
  PluginsMemo.ReadOnly := True;
  PluginsMemo.Lines.Text :=
    '- {app_name}' + #13#10 + #13#10 + #13#10 +
    '⚠️ Quand vous serez sur l’application, il vous sera demandé de vous connecter. Faites simplement « Login », puis relancez le logiciel !' + #13#10
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

procedure TopazRegKeysOFF;
begin
  RegDeleteKeyW(HKCU, 'SOFTWARE\\Topaz Labs LLC\\Topaz Video Enhance AI');
  RegDeleteKeyW(HKCU, 'SOFTWARE\\Topaz Labs LLC\\Video Enhance AI');
  RegDeleteKeyW(HKLM, 'SOFTWARE\\Topaz Labs LLC\\Topaz Video Enhance AI');
end;

procedure TopazRegKeysON;
begin
  RegWriteStringValue(HKCU, 'SOFTWARE\\Topaz Labs LLC\\Video Enhance AI', 'enableAnonDataCollection', 'false');
  RegWriteStringValue(HKCU, 'SOFTWARE\\Topaz Labs LLC\\Video Enhance AI', 'debugLogFileEnabled', 'false');
  RegWriteStringValue(HKLM, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Topaz Video Enhance AI 2.6.4', 'DisplayIcon', 'C:\\Program Files\\Topaz Labs LLC\\Topaz Video Enhance AI\\Topaz Video Enhance AI.exe, 0');
  RegWriteStringValue(HKLM, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Topaz Video Enhance AI 2.6.4', 'DisplayName', 'Topaz Video Enhance AI');
  RegWriteStringValue(HKLM, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Topaz Video Enhance AI 2.6.4', 'DisplayVersion', '2.6.4');
  RegWriteStringValue(HKLM, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Topaz Video Enhance AI 2.6.4', 'Publisher', 'Topaz Labs, LLC');
end;

procedure TopazInstall;
var
  InstallerPath: string;
begin
  WizardForm.StatusLabel.Caption := 'Installation de {app_name}...';
  InstallerPath := ExpandConstant('{{tmp}}\\{topaz_installer.name}');
  Exec(InstallerPath, '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    TopazRegKeysOFF;
    TopazInstall();
    WizardForm.StatusLabel.Caption := 'Copie des fichiers...';

    CopyFile(ExpandConstant('{{tmp}}\\Topaz Video Enhance AI.exe.BAK'), 'C:\\Program Files\\Topaz Labs LLC\\Topaz Video Enhance AI\\Topaz Video Enhance AI.exe.BAK', False);
    CopyFile(ExpandConstant('{{tmp}}\\version.dll'), 'C:\\Program Files\\Topaz Labs LLC\\Topaz Video Enhance AI\\version.dll', False);

    TopazRegKeysON;
  end;
end;
"""

    iss_code = iss_code.replace("{app_name}", app_name)\
                      .replace("{topaz_installer.name}", topaz_installer.name)

    INNO_SCRIPT = BUILD_DIR / "build.iss"
    INNO_SCRIPT.write_text(iss_code, encoding="utf-8")

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
