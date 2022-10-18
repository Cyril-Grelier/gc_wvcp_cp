Installation OR-Tools for Flatzinc

NB. La version 9.2.9972 de OR-Tools est compatible avec Minizinc 2.6.4
NB. La version 9.3.10497 de OR-Tools ne semble pas compatible avec Minizinc 2.6.4

1. Télécharger l'archive ORT de https://github.com/google/or-tools/releases/tag/v9.2
2. Décompresser dans le répertoire de votre choix
3. Lancez Minizinc IDE v6.4
4. Dans le menu Preferences > Solvers, choisir 'Add new ..' dans le menu déroulant puis renseigner les champs comme suit :
- Name : Google OR-Tools (au choix)
- Id: com.google.or-tools
- Version : 9.2.9972 
- Executable : le chemin vers le dossier .../or-tools_flatzinc_MacOsX-12.0.1_v9.2.9972/bin/fzn-or-tools
- Solver library path : le chemin vers le dossier .../or-tools_flatzinc_MacOsX-12.0.1_v9.2.9972/share/minizinc
- Flags : cocher 'Run with mzn2fzn' et 'Run with solns2out
- Command line flags : tout cocher sauf '-t'

Mininzinc créee le fichier de configuration correspondant dans
~/.minizinc/solvers/com.google.or-tools.msc
ou autre répertoire (cf https://www.minizinc.org/doc-2.3.0/en/fzn-spec.html#solver-configuration-files)