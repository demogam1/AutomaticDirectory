# Documentation: CreateGroup.ps1

## Description

Le script **CreateGroup.ps1** permet de créer un nouveau groupe dans Active Directory.  
Vous pouvez spécifier :  
- Le nom du groupe  
- L'Unité d'Organisation (OU) dans laquelle le groupe sera créé  
- La portée du groupe (Global, DomainLocal ou Universal)  
- Une description pour le groupe

## Prérequis

- **PowerShell 5.1** ou version supérieure.
- Le module **ActiveDirectory** installé sur la machine.
- Droits suffisants pour créer des groupes dans Active Directory.

## Paramètres

- **GroupName**  
  Le nom du groupe à créer.  
  *Exemple*: `ITSupport`

- **OU**  
  Le chemin (DN) de l'Unité d'Organisation où le groupe sera créé.  
  *Exemple*: `"OU=Groups,DC=example,DC=com"`

- **GroupScope**  
  La portée du groupe. Les valeurs possibles sont :  
  - `Global`
  - `DomainLocal`
  - `Universal`  
  *Exemple*: `Global`

- **Description**  
  Une description pour le groupe.  
  *Exemple*: `"Groupe pour le support informatique"`

## Exemples d'utilisation

### Exemple 1 : Créer un groupe pour le support informatique

```powershell
.\CreateGroup.ps1 -GroupName "ITSupport" -OU "OU=Groups,DC=example,DC=com" -GroupScope "Global" -Description "Groupe pour le support informatique"