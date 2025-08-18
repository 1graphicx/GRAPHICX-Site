const posts = [
    {
        title: "Windows Activator",
        description: "Permet d'activer rapidement les licences Windows 8, 10 et 11.",
        version: "8 / 10 / 11",
        thumbnail: "assets/images/windows_logo.png",
        tags: ["Windows", "System Tools"],
        file: "https://drive.google.com/uc?export=download&id=1aPJYoPgPy9cdD142CiustuiMhdnQLePU",
        size: "51 KB"
    },
    {
        title: "WinRAR Premium",
        description: "Version complète de WinRAR, sans interruptions de licence et avec toutes les fonctionnalités Premium.",
        version: ". Latest",
        thumbnail: "assets/images/winrar_logo.png",
        tags: ["Software", "Compression"],
        file: "https://drive.google.com/uc?export=download&id=1BMig6y78Fkx6tTnhD-fXgcshVMtX_Xoc",
        size: "1.8 MB"
    },
    {
        title: "LockHunter",
        description: "Permet de débloquer et supprimer facilement des fichiers utilisés ou verrouillés par d'autres programmes.",
        version: ". Latest",
        thumbnail: "assets/images/lockhunter_logo.png",
        tags: ["System Tools", "File Management"],
        file: "https://lockhunter.com/startdownload.htm?imm&v=&t=",
        size: "3.2 MB"
    },
    {
        title: "x64dbg",
        description: "Débogueur open source pour analyser et comprendre le comportement des logiciels.",
        version: "2025.07.04 - 16.03 (Snapshot)",
        thumbnail: "assets/images/x64dbg_logo.png",
        tags: ["Debugging", "Reverse Engineering"],
        file: "https://drive.google.com/uc?export=download&id=1lDQVyjOnC_HMZIT8Ws-xAHU0cihxoCTV",
        size: "23 MB"
    },
    {
        title: "Radare2",
        description: "Framework open source pour analyser et modifier des binaires en ligne de commande.",
        version: "6.0.2",
        thumbnail: "assets/images/radare2_logo.png",
        tags: ["Reverse Engineering", "Command Line"],
        file: "https://drive.google.com/uc?export=download&id=13J1j3DAurCqzbhjeX-W1JunBep8Jb3PD",
        size: "11.7 MB"
    },
    {
        title: "OllyDbg",
        description: "Débogueur 32-bit classique pour analyser le comportement de programmes Windows.",
        version: "2.01",
        thumbnail: "assets/images/ollydbg_logo.png",
        tags: ["Debugging", "Reverse Engineering"],
        file: "https://drive.google.com/uc?export=download&id=1CU3H3pBlm0NSs71vsqwYhJnMwtUMQto3",
        size: "7.2 MB"
    },
    {
        title: "Wireshark",
        description: "Analyseur de trafic réseau et inspection de paquets en profondeur.",
        version: "4.1.2",
        thumbnail: "assets/images/wireshark_logo.png",
        tags: ["Network Analysis", "Security"],
        file: "https://drive.google.com/uc?export=download&id=1biEXnwZQLNIeu0hItSts2wUWbPJQPkhq",
        size: "64.7 MB"
    },
    {
        title: "Metasploit Framework",
        description: "Version open-source de Metasploit, orientée ligne de commande pour tests d'intrusion et exploitation de vulnérabilités.",
        version: ". Latest",
        thumbnail: "assets/images/metasploit_logo.png",
        tags: ["Security", "Penetration Testing", "Open-Source"],
        file: "https://windows.metasploit.com/metasploitframework-latest.msi",
        size: "350 MB"
    },
    {
        title: "Metasploit Pro",
        description: "Version commerciale avec interface graphique et fonctionnalités avancées pour tests d'intrusion, reporting et automatisation.",
        version: ". Latest",
        thumbnail: "assets/images/metasploit_logo.png",
        tags: ["Security", "Penetration Testing", "Commercial", "GUI"],
        file: "https://downloads.metasploit.com/data/releases/metasploit-latest-windows-x64-installer.exe",
        size: "279 MB"
    },
    {
        title: "Hashcat",
        description: "Outil avancé de récupération et crack de mots de passe par GPU et CPU.",
        version: "7.1.0",
        thumbnail: "assets/images/hashcat_logo.png",
        tags: ["Password Cracking", "Security"],
        file: "https://drive.google.com/uc?export=download&id=1z2pdc2crTkhtEhZdMRY8oA1ir0eXtjAE",
        size: "22.8 MB"
    },
    {
        title: "John the Ripper",
        description: "Outil pour tester et récupérer des mots de passe sur différents systèmes.",
        version: "1.9.0",
        thumbnail: "assets/images/john_logo.png",
        tags: ["Password Cracking", "Security"],
        file: "https://drive.google.com/uc?export=download&id=1lvdAhcQpX-nKVFGmvMvTxlFJshrx4SBE",
        size: "31.2 MB"
    },
    {
        title: "Immunity Debugger",
        description: "Débogueur pour exploitation et reverse engineering sur Windows.",
        version: "1.85",
        thumbnail: "assets/images/immunitydbg_logo.png",
        tags: ["Debugging", "Reverse Engineering", "Security"],
        file: "https://drive.google.com/uc?export=download&id=1v_1IXWZhTy0jvb9Kz2uBgZvA_HB4VSrF",
        size: "21.7 MB"
    },
    {
        title: "WinDbg",
        description: "Débogueur avancé pour Windows avec intégration Visual Studio.",
        version: "Latest",
        thumbnail: "assets/images/windbg_logo.png",
        tags: ["Debugging", "Windows", "Professional"],
        file: "https://drive.google.com/uc?export=download&id=1P8pCSux6uL9Mizd_lXzbgVGVu467GHqu",
        size: "161 MB"
    },
    {
        title: "PE-sieve",
        description: "Outil pour analyser des malwares et détecter des injections.",
        version: "3.0",
        thumbnail: "assets/images/pe-sieve_logo.png",
        tags: ["Malware Analysis", "Security"],
        file: "https://drive.google.com/uc?export=download&id=1ZTDny1ovUwwGVPd3SGGoljro6CIeLp6E",
        size: "2.2 MB"
    },
    {
        title: "Java Decompiler GUI",
        description: "Interface graphique pour décompiler et analyser du bytecode Java.",
        version: "1.6.6",
        thumbnail: "assets/images/jdgui_logo.png",
        tags: ["Decompiler", "Java", "GUI"],
        file: "https://drive.google.com/uc?export=download&id=1yuqpkU4FTuUv4SRm9NvkbdNCSTr6xWis",
        size: "3.1 MB"
    },
    {
        title: "SweetScape 010 Editor Premium",
        description: "Éditeur hexadécimal avancé pour analyser, modifier et déboguer des fichiers binaires.",
        version: "15.0.2",
        thumbnail: "assets/images/010editor_logo.png",
        tags: ["Hex Editor", "Reverse Engineering"],
        file: "https://drive.usercontent.google.com/download?id=1OcKWObWy0FjwH8zMJlWPXj3VN4tauFj_&export=download&authuser=0",
        size: "34 MB"
    },
    {
        title: "Hex-Rays IDA Professional",
        description: "Outil de reverse engineering puissant pour désassembler et examiner des logiciels en profondeur.",
        version: "9.1",
        thumbnail: "assets/images/hexrays_logo.png",
        tags: ["Disassembler", "Reverse Engineering"],
        file: "https://drive.google.com/uc?export=download&id=1PAC8kLjvRwY8YSCy43OWkJZg_4ty2x-s",
        size: "396 MB"
    },
    {
        title: "Windows Defender Manager WDM",
        description: "Programme pour activer ou désactiver complètement Windows Defender.",
        version: "1",
        thumbnail: "assets/images/wdm_logo.png",
        tags: ["Windows", "Security"],
        file: "https://drive.google.com/uc?export=download&id=14tSSxpQZSgWbz7Zf456pzCvlEYKmGiyR",
        size: "4 MB"
    },
    {
        title: "Ghidra",
        description: "Suite de reverse engineering développée par la NSA pour analyser et décompiler des logiciels.",
        version: "11.4.1",
        thumbnail: "assets/images/ghidra_logo.png",
        tags: ["Decompiler", "Reverse Engineering"],
        file: "https://drive.google.com/uc?export=download&id=14u3CxeyUzfaQvH6fwRYdBrThTL4Kv_az",
        size: "537 MB"
    },
    {
        title: "ASM Visual",
        description: "Outil de reverse engineering pour analyser, décompiler et visualiser le code assembleur.",
        version: "1.1.8",
        thumbnail: "assets/images/asmvisual_logo.png",
        tags: ["Decompiler", "Reverse Engineering", "Assembly"],
        file: "https://drive.google.com/uc?export=download&id=12l9tYAy45Ab4_odBO-4ZyE1ZRvQo5S3V",
        size: "58 MB"
    },
    {
        title: "Cutter 2.0",
        description: "Interface graphique pour Radare2, simplifiant l'analyse et le débogage de binaires.",
        version: "2.1.1",
        thumbnail: "assets/images/cutter_logo.png",
        tags: ["Reverse Engineering", "GUI"],
        file: "https://drive.google.com/uc?export=download&id=1BRhdvrMQoq4sApEjivL3xjEl1RPU13Bz",
        size: "114 MB"
    },
    {
        title: "VirtualBox",
        description: "Logiciel de virtualisation pour créer et gérer des machines virtuelles en environnement isolé.",
        version: "7.2.0",
        thumbnail: "assets/images/vmware_logo.png",
        tags: ["Virtualization", "Testing"],
        file: "https://drive.google.com/uc?export=download&id=19vsSxkrkX3857qq8Nernntrk-EH7wUiS",
        size: "109 MB"
    },
    {
        title: "Nmap",
        description: "Scanner réseau open-source pour découvrir hôtes, ports et services.",
        version: "7.97",
        thumbnail: "assets/images/nmap_logo.png",
        tags: ["Network", "Security", "Scanning"],
        file: "https://drive.google.com/uc?export=download&id=1xB6xOqmqkX0mA7yCeOt38EMCipOoljJS",
        size: "54 MB"
    },
    {
        title: "Aircrack-ng",
        description: "Suite d'outils pour tester la sécurité des réseaux Wi-Fi.",
        version: "1.7",
        thumbnail: "assets/images/aircrack_logo.png",
        tags: ["Wi-Fi", "Security", "Cracking"],
        file: "https://drive.google.com/uc?export=download&id=1byAUt0AjZYpMsS8xeh411tRoYqfNox2f",
        size: "10 MB"
    },
    {
        title: "SQLmap",
        description: "Outil automatisé pour détecter et exploiter des injections SQL.",
        version: "1.9",
        thumbnail: "assets/images/sqlmap_logo.png",
        tags: ["Database", "Security", "Pentest"],
        file: "https://drive.google.com/uc?export=download&id=1r5b5EhK8cfpG1JnRMe3txBIXvTbT4J2x",
        size: "37 MB"
    },
    {
        title: "Binary Ninja",
        description: "Désassembleur moderne et outil d'analyse binaire.",
        version: "5.1",
        thumbnail: "assets/images/binaryninja_logo.png",
        tags: ["Reverse Engineering", "Disassembler"],
        file: "https://drive.google.com/uc?export=download&id=1wrVAwDp6SJQU4WnvFMzVd3MAKDf5B0Vj",
        size: "285 MB"
    },
    {
        title: "QEMU",
        description: "Émulateur et virtualiseur open-source.",
        version: "2025.08.14",
        thumbnail: "assets/images/qemu_logo.png",
        tags: ["Virtualization", "Emulation"],
        file: "https://drive.google.com/uc?export=download&id=13q6AHZ5MjpczFjnuf39MM4ApynU80Nxh",
        size: "166 MB"
    },
    {
        title: "System Informer",
        description: "Gestionnaire de tâches avancé pour Windows.",
        version: "3.2.25011",
        thumbnail: "assets/images/systeminformer_logo.png",
        tags: ["System Tools", "Windows"],
        file: "https://drive.google.com/uc?export=download&id=1etP9Dl9jkzRqyiT-SUt87IMA8BrllqAS",
        size: "6.7 MB"
    },
    {
        title: "HxD",
        description: "Éditeur hexadécimal léger et rapide.",
        version: "2.5",
        thumbnail: "assets/images/hxd_logo.png",
        tags: ["Hex Editor", "File Management"],
        file: "https://drive.google.com/uc?export=download&id=1HwMdFvUc71Yh9weFN9AhIfeV1N3w-fe-",
        size: "3.2 MB"
    },
    {
        title: "Sysinternals Suite",
        description: "Collection d'outils avancés de diagnostic système par Microsoft.",
        version: ". Latest",
        thumbnail: "assets/images/sysinternals_logo.png",
        tags: ["System Tools", "Windows"],
        file: "https://drive.google.com/uc?export=download&id=1Ik_JmgAW7g1uJDLmdg_hpGlEWm6drOU9",
        size: "67 MB"
    },
    {
        title: "Hydra",
        description: "Crackeur rapide de mots de passe pour de multiples protocoles.",
        version: "Latest",
        thumbnail: "assets/images/hydra_logo.png",
        tags: ["Password Cracking", "Security"],
        file: "https://github.com/vanhauser-thc/thc-hydra",
        size: "Variable"
    },
    {
        title: "Maltego CE",
        description: "Outil d'investigation OSINT et de cartographie de relations.",
        version: "Latest",
        thumbnail: "assets/images/maltego_logo.png",
        tags: ["OSINT", "Investigation", "Security"],
        file: "https://www.maltego.com/downloads/",
        size: "Variable"
    },
    {
        title: "Frida",
        description: "Framework d'instrumentation dynamique pour analyser et injecter du code.",
        version: "Latest",
        thumbnail: "assets/images/frida_logo.png",
        tags: ["Debugging", "Reverse Engineering"],
        file: "https://frida.re/",
        size: "Variable"
    },
    {
        title: "Capstone",
        description: "Framework de désassemblage multi-plateformes.",
        version: "Latest",
        thumbnail: "assets/images/capstone_logo.png",
        tags: ["Disassembler", "Reverse Engineering"],
        file: "https://www.capstone-engine.org/download.html",
        size: "Variable"
    },
    {
        title: "angr",
        description: "Framework Python d'analyse binaire et exécution symbolique.",
        version: "Latest",
        thumbnail: "assets/images/angr_logo.png",
        tags: ["Binary Analysis", "Reverse Engineering"],
        file: "https://github.com/angr/angr",
        size: "Variable"
    },
];