import os
import subprocess
import sys
import shutil
import time
import re
import zipfile
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

def patch_file(binary_path, replacements):
    try:
        if not os.path.exists(binary_path):
            return

        with open(binary_path, "rb") as f:
            data = f.read()

        modified = False

        for original, patched in replacements:
            index = data.find(original)
            if index != -1:
                data = data[:index] + patched + data[index + len(original):]
                modified = True

        if modified:
            with open(binary_path, "wb") as f:
                f.write(data)

    except Exception:
        pass

def patch_plugins():
    # Liste des plugins communs
    common_targets = [
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\AlRoColorWarp.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\Aurora.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\ChromaticAberration.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\ChromaticDistortion.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesAlphaBlur.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesASCII.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesDistortion.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesEasyGlow.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesEasyGodray.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesGlow.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHalftone.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHeightRelight.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHologram.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHyperGlitch.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesLongGradient.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesLongShadow.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesPixelate.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesRingBokeh.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesUnmult.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesVHS.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CubicFractal.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\Kaleidoscoper.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LygiaKuwahara.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LygiaNoiseBlur.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\SplitScreen.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionChromaticAberration.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCratesASCII.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCratesHyperGlitch.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCRTFactory.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionHologram.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionVHS.aex",
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CRTFactory.aex",

    ]

    # Liste des plugins spécifiques LaForge
    special_targets = [
        r"C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LaForge.aex"
    ]

    # Remplacements bruts à effectuer (spécifiques LaForge)
    byte_replacements = [
        (
            bytes.fromhex("C30F1F8400000000"),
            bytes.fromhex("C3E90F0200009090")
        ),
        (
            bytes.fromhex("50462045666665637420554920537569746500000000000052656672657368204C6963656E7365"),
            bytes.fromhex("504620456666656374205549205375697465000000000000475241504849435820202020202020")
        )
    ]

    for path in special_targets:
        patch_file(path, byte_replacements)

    for path in common_targets:
        patch_file(path, byte_replacements)

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

# --- MAIN ---

def main():
    if len(sys.argv) < 3:
        print('[!] Usage : python MaxonRedGiant.py chemin\\vers\\RedGiant.exe chemin\\vers\\MaxonApp.exe')
        sys.exit(1)

    AlRoColorWarp = Path(sys.argv[1])
    Aurora = Path(sys.argv[2])
    CratesDistortion = Path(sys.argv[3])
    CratesEasyGlow = Path(sys.argv[4])
    CratesEasyGodray = Path(sys.argv[5])
    CratesGlow = Path(sys.argv[6])
    CratesHalftone = Path(sys.argv[7])
    CratesHeightRelight = Path(sys.argv[8])
    CratesHologram = Path(sys.argv[9])
    CratesLongGradient = Path(sys.argv[10])
    CratesLongShadow = Path(sys.argv[11])
    CratesPixelate = Path(sys.argv[12])
    CratesRingBokeh = Path(sys.argv[13])
    CratesUnmult = Path(sys.argv[14])
    CratesVHS = Path(sys.argv[15])
    CubicFractal = Path(sys.argv[16])
    Kaleidoscoper = Path(sys.argv[17])
    LaForge = Path(sys.argv[18])
    LygiaKuwahara = Path(sys.argv[19])
    LygiaNoiseBlur = Path(sys.argv[20])
    SplitScreen = Path(sys.argv[21])
    TransitionCratesHyperGlitch = Path(sys.argv[22])
    ChromaticDistortion = Path(sys.argv[23])
    forgeVkLoader = Path(sys.argv[24])
    TransitionVHS = Path(sys.argv[25])
    TransitionHologram = Path(sys.argv[26])
    TransitionCratesASCII = Path(sys.argv[27])
    TransitionChromaticAberration = Path(sys.argv[28])
    TransitionCRTFactory = Path(sys.argv[29])
    CratesHyperGlitch = Path(sys.argv[30])
    CratesEdgeBlur = Path(sys.argv[31])
    CratesAlphaBlur = Path(sys.argv[32])
    CratesASCII = Path(sys.argv[33])
    ChromaticAberration = Path(sys.argv[34])
    CRTFactory = Path(sys.argv[35])

    for f in [
        AlRoColorWarp, Aurora, CratesDistortion, CratesEasyGlow, CratesEasyGodray, CratesGlow, CratesHalftone, CratesHeightRelight, CratesHologram, CratesLongGradient, CratesLongShadow, CratesPixelate, CratesRingBokeh, CratesUnmult, CratesVHS, CubicFractal, Kaleidoscoper, LaForge, LygiaKuwahara, LygiaNoiseBlur, SplitScreen, TransitionCratesHyperGlitch, ChromaticDistortion, forgeVkLoader, TransitionVHS, TransitionHologram, TransitionCratesASCII, TransitionChromaticAberration, TransitionCRTFactory, CratesHyperGlitch, CratesEdgeBlur, CratesAlphaBlur, CratesASCII, ChromaticAberration, CRTFactory
    ]:
        if not f.exists():
            print(f"[!] {f} introuvable")
            sys.exit(1)


    if not safe_rmtree(BUILD_DIR):
        sys.exit(1)
        
    app_name = "LaForge Suite"
    version = "v1.4.2"
    output_name = f"{app_name} {version}"

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
AppName=LaForge Suite
AppVersion=1.4.2
DefaultDirName={{pf}}\\Laforge Suite
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no
OutputBaseFilename=LaForge Suite {version}
Compression=lzma
SolidCompression=yes
DisableReadyPage=yes
DisableFinishedPage=yes
SetupIconFile="{str(Path(__file__).parent.parent / 'logo.ico')}"

[Files]
Source: "{str(AlRoColorWarp)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(Aurora)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesDistortion)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesEasyGlow)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesEasyGodray)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesGlow)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesHalftone)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesHeightRelight)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesHologram)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesLongGradient)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesLongShadow)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesPixelate)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesRingBokeh)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesUnmult)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesVHS)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CubicFractal)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(Kaleidoscoper)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(LaForge)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(LygiaKuwahara)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(LygiaNoiseBlur)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(SplitScreen)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionCratesHyperGlitch)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(ChromaticDistortion)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionVHS)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionHologram)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionCratesASCII)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionChromaticAberration)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(TransitionCRTFactory)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesHyperGlitch)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesEdgeBlur)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesAlphaBlur)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CratesASCII)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(ChromaticAberration)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(CRTFactory)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(forgeVkLoader)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall
Source: "{str(autopatcher_exe)}"; DestDir: "{{tmp}}"; Flags: deleteafterinstall

[Code]
var
  MadeByButton: TNewButton;
  InfoPage: TWizardPage;
  PluginsMemo: TNewMemo;
  ResultCode: Integer;
  TargetDir: string;
  
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
    '- LaForge Suite';
end;

procedure Install;
begin  
  ForceDirectories('C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite');
  CopyFile(ExpandConstant('{{tmp}}\\AlRoColorWarp.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\AlRoColorWarp.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\Aurora.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\Aurora.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesDistortion.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesDistortion.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesEasyGlow.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesEasyGlow.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesEasyGodray.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesEasyGodray.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesGlow.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesGlow.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesHalftone.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHalftone.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesHeightRelight.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHeightRelight.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesHologram.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHologram.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesLongGradient.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesLongGradient.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesLongShadow.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesLongShadow.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesPixelate.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesPixelate.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesRingBokeh.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesRingBokeh.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesUnmult.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesUnmult.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesVHS.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesVHS.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CubicFractal.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CubicFractal.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\Kaleidoscoper.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\Kaleidoscoper.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\LaForge.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LaForge.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\LygiaKuwahara.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LygiaKuwahara.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\LygiaNoiseBlur.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\LygiaNoiseBlur.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\SplitScreen.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\SplitScreen.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionCratesHyperGlitch.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCratesHyperGlitch.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\ChromaticDistortion.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\ChromaticDistortion.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionVHS.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionVHS.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionHologram.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionHologram.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionCratesASCII.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCratesASCII.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionChromaticAberration.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionChromaticAberration.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\TransitionCRTFactory.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\TransitionCRTFactory.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesHyperGlitch.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesHyperGlitch.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesEdgeBlur.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesEdgeBlur.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesAlphaBlur.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesAlphaBlur.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CratesASCII.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CratesASCII.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\ChromaticAberration.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\ChromaticAberration.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\CRTFactory.aex'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\CRTFactory.aex', False);
  CopyFile(ExpandConstant('{{tmp}}\\forgeVkLoader.dll'), 'C:\\Program Files\\Adobe\\Common\\Plug-ins\\7.0\\MediaCore\\Laforge Suite\\forgeVkLoader.dll', False);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  Install;
  WizardForm.StatusLabel.Caption := 'Cracking...';
  Exec(ExpandConstant('{{tmp}}\\{autopatcher_exe.name}'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
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