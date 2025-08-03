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

# -- FILES

BORISFX_FILES = RESSOURCES_DIR / "files" / "Boris" / "Continuum" 

PD_BORISFX_CONTINUUM_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "Continuum"
PD_BORISFX_CONTINUUMAE_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "ContinuumAE"
PD_BORISFX_EMITTERLIBRARIES_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "EmitterLibraries"
PD_BORISFX_PI3DMODELS_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "PI3DModels"
PD_BORISFX_PIFACTORYPRESETS_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "PIFactoryPresets"
PD_BORISFX_USEREMITTERLIBRARIES_FILES = BORISFX_FILES / "Program Data" / "BorisFX"/ "UserEmitterLibraries"

PD_MICROSOFT_FILES = BORISFX_FILES / "Program Data" / "Microsoft" /"Boris FX Continuum AE"

PF_BORISFX_CONTINUUMAE_FILES = BORISFX_FILES / "Program Files" / "BorisFX" / "ContinuumAE"
PF_MEDIACORE_CONTINUUMAE_FILES = BORISFX_FILES / "Program Files" / "Mediacore" / "ContinuumAE"

PROGRAM_DATA = Path("C:/ProgramData")
PROGRAM_FILES = Path("C:/Program Files")

PD_BORISFX_CONTINUUM = PROGRAM_DATA / "BorisFX"/ "Continuum"
PD_BORISFX_CONTINUUMAE = PROGRAM_DATA / "BorisFX"/ "ContinuumAE"
PD_BORISFX_EMITTERLIBRARIES = PROGRAM_DATA / "BorisFX"/ "EmitterLibraries"
PD_BORISFX_PI3DMODELS = PROGRAM_DATA / "BorisFX"/ "PI3DModels"
PD_BORISFX_PIFACTORYPRESETS = PROGRAM_DATA / "BorisFX"/ "PIFactoryPresets"
PD_BORISFX_USEREMITTERLIBRARIES = PROGRAM_DATA / "BorisFX"/ "UserEmitterLibraries"

PD_MICROSOFT = PROGRAM_DATA / "Microsoft" /"Boris FX Continuum AE"

PF_BORISFX_CONTINUUMAE = BORISFX_FILES / "Program Files" / "BorisFX" / "ContinuumAE"
PF_MEDIACORE_CONTINUUMAE = BORISFX_FILES / "Program Files" / "Mediacore" / "ContinuumAE"


# --- UTILS ---

def run_command_silent(cmd):
    CREATE_NO_WINDOW = 0x08000000
    proc = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, creationflags=CREATE_NO_WINDOW
    )
    return proc.returncode, proc.stdout, proc.stderr

def safe_rmtree(path, retries=5, delay=1):
    for _ in range(retries):
        try:
            if path.exists():
                shutil.rmtree(path)
            return True
        except PermissionError:
            time.sleep(delay)
    return False

def extract_version(filename):
    match = re.search(r'(\d+\.\d+\.\d+)', filename)
    return match.group(1) if match else "0.0.0"

def copy_tree(src: Path, dst: Path):
    if src.exists():
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src, dst)

# --- MAIN ---

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    borisfx_installer = Path(sys.argv[1])
    if not borisfx_installer.exists():
        sys.exit(1)

    borisfx_version = extract_version(borisfx_installer.name)

    try:
        subprocess.run([str(borisfx_installer)], check=True)
    except subprocess.CalledProcessError:
        sys.exit(1)

    copy_tree(PD_BORISFX_CONTINUUM, PD_BORISFX_CONTINUUM_FILES)
    copy_tree(PD_BORISFX_CONTINUUMAE, PD_BORISFX_CONTINUUMAE_FILES)
    copy_tree(PD_BORISFX_EMITTERLIBRARIES, PD_BORISFX_EMITTERLIBRARIES_FILES)
    copy_tree(PD_BORISFX_PI3DMODELS, PD_BORISFX_PI3DMODELS_FILES)
    copy_tree(PD_BORISFX_PIFACTORYPRESETS, PD_BORISFX_PIFACTORYPRESETS_FILES)
    copy_tree(PD_BORISFX_USEREMITTERLIBRARIES, PD_BORISFX_USEREMITTERLIBRARIES_FILES)
    copy_tree(PD_MICROSOFT, PD_MICROSOFT_FILES)
    copy_tree(PF_BORISFX_CONTINUUMAE, PF_BORISFX_CONTINUUMAE_FILES)
    copy_tree(PF_MEDIACORE_CONTINUUMAE, PF_MEDIACORE_CONTINUUMAE_FILES)

    UNWANTED_FILES = [
        "uninstaller.exe",
        "Readme.txt",
        "TrialInfo.dat"
    ]

    for file in UNWANTED_FILES:
        target_file = PF_BORISFX_CONTINUUMAE_FILES / file
        if target_file.exists():
            try:
                target_file.unlink()
            except Exception:
                pass

    borisfx_version = extract_version(borisfx_installer.name)
    app_name = "Boris FX Continuum"
    output_name = f"{app_name} v{borisfx_version}"

    if not safe_rmtree(BUILD_DIR):
        sys.exit(1)

    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    INSTALLERS_DIR.mkdir(parents=True, exist_ok=True)

    iss_code = f"""[Setup]
AppName={app_name}
AppVersion={borisfx_version}
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
Source: "{str(PD_BORISFX_CONTINUUM_FILES)}"; DestDir: "{str(PD_BORISFX_CONTINUUM)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PD_BORISFX_CONTINUUMAE_FILES)}"; DestDir: "{str(PD_BORISFX_CONTINUUMAE)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PD_BORISFX_EMITTERLIBRARIES_FILES)}"; DestDir: "{str(PD_BORISFX_EMITTERLIBRARIES)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PD_BORISFX_PI3DMODELS_FILES)}"; DestDir: "{str(PD_BORISFX_PI3DMODELS)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PD_BORISFX_PIFACTORYPRESETS_FILES)}"; DestDir: "{str(PD_BORISFX_PIFACTORYPRESETS)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PD_BORISFX_USEREMITTERLIBRARIES_FILES)}"; DestDir: "{str(PD_BORISFX_USEREMITTERLIBRARIES)}"; Flags: ignoreversion recursesubdirs createallsubdirs

Source: "{str(PD_MICROSOFT_FILES)}"; DestDir: "{str(PD_MICROSOFT)}"; Flags: ignoreversion recursesubdirs createallsubdirs

Source: "{str(PF_BORISFX_CONTINUUMAE_FILES)}"; DestDir: "{str(PF_BORISFX_CONTINUUMAE)}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{str(PF_MEDIACORE_CONTINUUMAE_FILES)}"; DestDir: "{str(PF_MEDIACORE_CONTINUUMAE)}"; Flags: ignoreversion recursesubdirs createallsubdirs

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
    '- Boris FX Continuum';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LicFilePath, DestLicPath: string;
begin
  if CurStep = ssPostInstall then
  begin
    RedGiantInstall;
    WizardForm.StatusLabel.Caption := 'Cracking...';
    LicFilePath := ExpandConstant('{{tmp}}\\GRAPHICX.lic');
    DestLicPath := 'C:\\ProgramData\\GenArts\\rlm';

    if not DirExists('C:\\ProgramData\\GenArts\\rlm') then
      ForceDirectories('C:\\ProgramData\\GenArts\\rlm');

    SaveStringToFile(
    LicFilePath,
    'LICENSE genarts bfxsuite 999999999.9 permanent uncounted hostid=000000000000 options=ae:9,avx:9,ofx:9,+ps:9' + #13#10 +
    'LICENSE genarts sapphire_ae_ofx_sparks_avx_104 20321026.0 permanent uncounted hostid=000000000000 options=ae:9,avx:9,ofx:9,+ps:9' + #13#10 +
    'LICENSE genarts sapphire 20321026.0 permanent uncounted hostid=000000000000 options=ae:9,avx:9,ofx:9,+ps:9' + #13#10 +
    'LICENSE genarts crumplepop_all_gui 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccae 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccaemulti 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccavxmulti 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccofx 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccaerender 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bccaemultirender 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts bundlemultihost-bcc-mocha-sapphire-r1 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochaPro_plugin 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochaVR_plugin 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp-adobe 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp-adobe-r 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp-multihost 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp-multihost-so 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mpp-multihost-so-r 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochac4d 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.soho 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.adjusttrack 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.image 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.track 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.python 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.update 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.core 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.remove 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.matte 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.stable 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.grain 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.lens 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.primatte 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.layerfx 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.mv 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.imp5 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.patch 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts mochapro.warper 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts silhouette 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts optics 20321026.0 permanent uncounted hostid=000000000000' + #13#10 +
    'LICENSE genarts r1 20321026.0 permanent uncounted hostid=000000000000' + #13#10,
    False);

    CopyFile(ExpandConstant('{{tmp}}\\Red Giant Service.exe'), 'C:\\Program Files\\Red Giant\\Services\\Red Giant Service.exe', False);

    Exec('cmd.exe', '/C copy /Y "' + LicFilePath + '" "' + DestLicPath + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
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