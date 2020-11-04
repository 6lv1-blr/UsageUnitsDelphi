# UsageUnitsDelphi

Permet de chercher les fichiers .pas de vos sources qui ne sont pas utilisés.
attention cela ce fait en cherchant un fichier dcu créé. donc il faut bien compiler le projet avant.

l'avantage étant de ne pas avoir à chercher les différentes clauses uses dans les fichiers.

Cela permet de détecter qu'un fichier Unit4.pas n'est pas utilisé dans aucun "uses"
pas que vos "uses" contient Unit4 mais qu'on pourrait s'en passer
