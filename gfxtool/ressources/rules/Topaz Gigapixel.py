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

# --- PATCHER À INJECTER ---

PATCHER_CODE = r'''
import os

def patch_plugins():
    targets_info = [
        {
            "path": r"C:\Program Files\Topaz Labs LLC\Topaz Gigapixel AI\rlm1611_http.dll",
            "signature": bytes.fromhex("7510488B442460C74058DCFFFFFF33C0EB6D448B4C24684533C0488B542448488B4C2440E89B15010089442420837C242000"),
            "patch_bytes": bytes.fromhex("EB10488B4424608B4C242089485833C0EB3B488B4424488B90000E0000488B4424408B8824020000E825AF010089442420837C242000EB"),
            "end_pattern": bytes.fromhex("10488B4424608B4C242089485833C0EB05")
        },
        {
            "path": r"C:\Program Files\Topaz Labs LLC\Topaz Gigapixel AI\rlm1611.dll",
            "signature": bytes.fromhex("C07510488B442460C74058DCFFFFFF33C0EB6D448B4C24684533C0488B542448488B4C2440E87B20030089442420837C242000"),
            "patch_bytes": bytes.fromhex("EB10488B4424608B4C242089485833C0EB3B488B4424488B90000E0000488B4424408B8824020000E81564030089442420837C242000EB"),
            "end_pattern": bytes.fromhex("10488B4424608B4C242089485833C0EB05")
        },
        {
            "path": r"C:\Program Files\Topaz Labs LLC\Topaz Gigapixel AI\gigapixel.exe",
            "signature": bytes.fromhex("621100488D4DA8FF15D628520190488BD0488BCBFF15392D520190488D4DA8FF15762B520190488D4C2450FF15DA2C5201458BECE94F170000488BCBE8C807FAFF84C0"),
            "patch_bytes": bytes.fromhex("E98D0000009090"),
            "end_pattern": bytes.fromhex("15BC3F5201488B")
        }
    ]

    for target in targets_info:
        binary_path = target["path"]
        if not os.path.exists(binary_path):
            continue
        try:
            with open(binary_path, "rb") as f:
                data = f.read()
            start = data.find(target["signature"])
            if start == -1:
                continue
            search_from = start + len(target["signature"])
            end = data.find(target["end_pattern"], search_from)
            if end == -1:
                continue
            patched_data = data[:search_from] + target["patch_bytes"] + data[end:]
            with open(binary_path, "wb") as f:
                f.write(patched_data)
        except Exception:
            continue

if __name__ == "__main__":
    patch_plugins()
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
        print('[!] Usage : python build_installer.py chemin\\vers\\010Editor.exe')
        sys.exit(1)

    topaz_installer = Path(sys.argv[1])
    if not topaz_installer.exists():
        print(f"[!] {topaz_installer} introuvable")
        sys.exit(1)

    topaz_version = extract_version(topaz_installer.name)
    app_name = "Topaz Gigapixel AI"
    output_name = f"{app_name} v{topaz_version}"

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
Source: "{str(autopatcher_exe)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall

[Code]
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
    '- {app_name}';
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

procedure TopazInstall;
var
  MsiPath: string;
begin
  WizardForm.StatusLabel.Caption := 'Installation de {app_name}...';
  MsiPath := ExpandConstant('{{tmp}}\\{topaz_installer.name}');
  Exec('msiexec.exe', '/i "' + MsiPath + '"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LicFilePath, DestLicPath: string;
begin
  if CurStep = ssPostInstall then
  begin
    TopazInstall();
    WizardForm.StatusLabel.Caption := 'Cracking...';

    LicFilePath := ExpandConstant('{{tmp}}\\GRAPHICX.lic');
    DestLicPath := 'C:\\ProgramData\\Topaz Labs LLC\\{app_name}\\models\\GRAPHICX.lic';

    if not DirExists('C:\\ProgramData\\Topaz Labs LLC\\{app_name}\\models') then
      ForceDirectories('C:\\ProgramData\\Topaz Labs LLC\\{app_name}\\models');

    SaveStringToFile(
      LicFilePath,
      'LICENSE topazlabs gp_floating 99999999 permanent uncounted hostid=ANY issuer=GRAPHICX customer=GRAPHICX akey=0000-0000-0000-0000-0000 _ck=00 sig="00"',
      False);

    Exec('cmd.exe', '/C copy /Y "' + LicFilePath + '" "' + DestLicPath + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    Exec(ExpandConstant('{{tmp}}\\{autopatcher_exe.name}'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
"""

# Remplacement Python avant d’écrire dans le fichier .iss
    iss_code = iss_code.replace("{app_name}", app_name)\
                    .replace("{topaz_installer.name}", topaz_installer.name)\
                    .replace("{autopatcher_exe.name}", autopatcher_exe.name)\
                    .replace("{{tmp}}", "{tmp}")

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