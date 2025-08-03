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

VERSION_DLL = RESSOURCES_DIR / "files" / "010Editor" / "version.dll"
VERSION_BLAKE3 = RESSOURCES_DIR / "files" / "010Editor" / "version.blake3"

# --- PATCHER À INJECTER ---

PATCHER_CODE = r'''
import os
import sys
from pathlib import Path
from datetime import datetime

def log(message):
    log_path = Path(sys.executable).parent / "log.txt"
    with open(log_path, "a", encoding="utf-8") as f:
        timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
        f.write(f"{timestamp} {message}\n")

def patch_plugins():
    patches = [
        {
            "name": "graphicx-licenses",
            "signature": bytes.fromhex("30 31 30 65 64 69 74 6F 72 2E 70 68 70 3F 6E 61 6D 65 3D 00 00 00 00 00 00 00 00 00 00 00 00 00 68 74 74 70 73 3A 2F 2F"),
            "patch": bytes.fromhex("72 65 6E 74 72 79 2E 63 6F 2F 67 72 61 70 68 69 63 78 2D 6C 69 63 65 6E 73 65 73 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F 2F"),
            "end_pattern": bytes.fromhex("00 00 00 00 00 00 00 00 00 00 00 00 00 26 52 65 6D 6F 76 65")
        },
        {
            "name": "guide",
            "signature": bytes.fromhex("6E 67 65 20 74 68 65 20 6C 69 63 65 6E 73 65 2E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"),
            "patch": bytes.fromhex("4E 61 6D 65 20 3A 20 47 52 41 50 48 49 43 58 3C 62 72 3E 4C 69 63 65 6E 73 65 20 3A 20 36 37 39 33 2D 31 31 41 43 2D 38 41 32 41 2D 45 36 33 41 2D 35 33 42 46 3C 62 72 3E 3C 62 72 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"),
            "end_pattern": bytes.fromhex("00 00 00")
        },
        {
            "name": "guide clear",
            "signature": bytes.fromhex("2D 35 33 42 46 3C 62 72 3E 3C 62 72 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"),
            "patch": bytes.fromhex("00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"),
            "end_pattern": bytes.fromhex("20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 4C 69 63 65 6E 73 65 20 41 63 74 69 76 61 74 65 64 20 2D 20 53 69 6E 67 6C 65 20 55 73 65 72 20 4C 69 63 65 6E 73 65")
        },
        {
            "name": "liens",
            "signature": bytes.fromhex("3C 61 20 68 72 65 66 3D 22 75 70 67 72 61 64 65 22 3E 50 75 72 63 68 61 73 65 20 61 6E 20 75 70 67 72 61 64 65 20 66 6F 72 20 30 31 30 20 45 64 69 74 6F 72 2E 3C 2F 61 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3C 61 20 68 72 65 66 3D 22 70 75 72 63 68 61 73 65 22 3E"),
            "patch": bytes.fromhex("47 52 41 50 48 49 43 58 20 53 69 74 65 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3C 2F 61 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3C 61 20 68 72 65 66 3D 22 65 78 74 65 6E 64 22 3E 50 75 72 63 68 61 73 65 20 61 6E 20 65 78 74 65 6E 73 69 6F 6E 20 74 6F 20 73 75 70 70 6F 72 74 2F 6D 61 69 6E 74 65 6E 61 6E 63 65 2E 3C 2F 61 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3C 61 20 68 72 65 66 3D 27 6C 6F 73 74 27 3E 47 52 41 50 48 49 43 58 20 4C 69 63 65 6E 73 65 73 00 00 00 00 00 00"),
            "end_pattern": bytes.fromhex("3C 2F 61 3E 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3C 61 20 68 72 65 66 3D 27 72 65 6D 6F 76 65 27 3E 52 65 6D 6F 76 65 20 6D 79 20 6C 69 63 65 6E 73 65 20 66 72 6F 6D 20 74 68 69 73 20 6D 61 63 68 69 6E 65 2E 3C 2F 61")
        },
        {
            "name": "graphicx-links",
            "signature": bytes.fromhex("6D 61 72 6B 73 2E 00 00 00 00 00 00 00 00 00 00 68 74 74 70 73 3A 2F 2F 77 77 77 2E 73 77 65 65 74 73 63 61 70 65 2E 63 6F 6D 2F 30 31 30 65 64 69 74 6F 72 2F 00 00 00 00 00 00 00 00 00 00 00 68 74 74 70 73 3A 2F 2F"),
            "patch": bytes.fromhex("72 65 6E 74 72 79 2E 63 6F 2F 67 72 61 70 68 69 63 78 2D 6C 69 6E 6B 73"),
            "end_pattern": bytes.fromhex("2F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 43 6F 75 6C 64 20 6E 6F 74 20 63 6F 6E 6E 65 63 74 20 74 6F 20 73 65 72 76 65 72 2E 20 50 6C 65 61 73 65 20 63 68 65 63 6B 20 79 6F 75 72 20 69 6E 74 65 72 6E 65 74 20 63 6F 6E 6E 65 63 74 69 6F 6E 20 61 6E 64 20 79 6F 75 72 20 66 69 72 65")
        },
    ]

    targets = [
        r"C:\Program Files\010 Editor\010Editor.exe"
    ]

    for binary_path in targets:
        log(f"Analyse de : {binary_path}")
        if not os.path.exists(binary_path):
            log("[!] Fichier introuvable")
            continue

        try:
            with open(binary_path, "rb") as f:
                data = f.read()

            for patch in patches:
                log(f"--- {patch['name']} ---")
                signature = patch["signature"]
                patch_bytes = patch["patch"]
                end_pattern = patch["end_pattern"]

                start = data.find(signature)
                if start == -1:
                    log("[!] Signature non trouvée")
                    continue

                search_from = start + len(signature)
                end = data.find(end_pattern, search_from)
                if end == -1:
                    log("[!] Fin de pattern non trouvée")
                    continue

                log(f"[+] Patch possible de {search_from} à {end} (taille: {end - search_from})")

                data = data[:search_from] + patch_bytes + data[end:]
                log("[+] Patch appliqué avec succès !")

            with open(binary_path, "wb") as f:
                f.write(data)

        except Exception as e:
            log(f"[!] Erreur pendant le patch : {e}")

if __name__ == "__main__":
    try:
        patch_plugins()
    except Exception as e:
        log(f"[!] Erreur fatale : {e}")
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
    if len(sys.argv) < 2:
        print('[!] Usage : python build_installer.py chemin\\vers\\010Editor.exe')
        sys.exit(1)

    editor_installer = Path(sys.argv[1])
    if not editor_installer.exists():
        print(f"[!] {editor_installer} introuvable")
        sys.exit(1)

    editor_version = extract_version(editor_installer.name)
    app_name = "SweetScape 010 Editor"
    output_name = f"{app_name} v{editor_version}"

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

    # Génération du script Inno Setup
    iss_code = f"""[Setup]
AppName={app_name}
AppVersion={editor_version}
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
Source: "{str(editor_installer)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(autopatcher_exe)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(VERSION_DLL)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(VERSION_BLAKE3)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall

[Code]
var
  MadeByButton: TNewButton;
  InfoPage: TWizardPage;
  PluginsMemo: TNewMemo;
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
    '- 010 Editor';
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

procedure EditorInstall;
begin
  WizardForm.StatusLabel.Caption := 'Installation de 010 Editor...';
  Exec(ExpandConstant('{{tmp}}\\{editor_installer.name}'), '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
end;

procedure EditorCloseAll;
begin
  while True do
  begin
    if IsProcessRunning('010Editor.exe') then
    begin
      KillProcess('010Editor.exe');
      Exit;
    end;
    Sleep(1000);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  TargetDir, TargetFile: string;
begin
  if CurStep = ssPostInstall then
  begin
    EditorInstall;
    WizardForm.StatusLabel.Caption := 'Cracking...';
    
    TargetDir := 'C:\\Program Files\\010 Editor\\';
    TargetFile := TargetDir + '010Editor.exe';

    if FileExists(TargetFile) then
      DeleteFile(TargetFile);    
    
    CopyFile(ExpandConstant('{{tmp}}\\version.dll'), TargetDir + 'version.dll', False);
    CopyFile(ExpandConstant('{{tmp}}\\version.blake3'), TargetDir + 'version.blake3', False);
    EditorCloseAll;
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