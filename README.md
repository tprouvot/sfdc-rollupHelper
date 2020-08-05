
# Basé sur le  [modèle de Thibault Weber](https://gist.github.com/grotib/838a40928d17d241f974319f04336bc3)


## 1. Créer un Trigger sur l'objet enfant
(Ou réutiliser un Trigger existant car il ne faut pas plus d'un Trigger par objet)

Les événements suivants doivent être invoqués:  
**after insert, after update, after delete, after undelete**

**Exemple:**
```
Trigger MonObjetEnfantTrigger on MonObjetEnfant__c (after insert, after update, after delete, after undelete){

}
```
## 2. Instancier le RollupHelper
**Exemple:**
```
Trigger MonObjetEnfantTrigger on MonObjetEnfant__c (after insert, after update, after delete, after undelete){

    RollupHelper rolls = new RollupHelper(MonObjetEnfant__c.MonChampLookupVersLeParent__c);

    //Ici on va déclarer nos différents Rollup (Cf 3. )

    rolls.process();

}  
```
Si vous utilisez déjà la TriggerFactory, pas de problème vous pouvez instancier le RollupHelper après le
```TriggerFactory.createHandler(MonObjetEnfant__c.sObjectType);```

## 3. Déclaration des Rollups
Vous pouvez déclarer autant de Rollup que vous voulez.
Ces Rollups peuvent être de différents types:

- COUNT
- SUM
- MIN
- MAX
- CONCAT  

**Rollup COUNT**
```
RollupHelper.Rollup countRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c); 
rolls.addRollup(countRollup);
```
*"countRollup" est un nom de variable, vous pouvez mettre ce que vous voulez ;)*

**Rollup SUM**
```
RollupHelper.Rollup sumRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c, RollupHelper.Aggregation.SUM, MonObjetEnfant__c.ChampEnfantAsommer__c);
rolls.addRollup(sumRollup);
```
**Rollup MAX**
```
RollupHelper.Rollup maxRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c, RollupHelper.Aggregation.MAX, MonObjetEnfant__c.ChampEnfantDontIlFautTrouverLeMax__c);
rolls.addRollup(maxRollup);
```
**Rollup MIN**
```
RollupHelper.Rollup minRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c, RollupHelper.Aggregation.MIN, MonObjetEnfant__c.ChampEnfantDontIlFautTrouverLeMin__c);
rolls.addRollup(minRollup);
```
**Rollup CONCAT**
Permet de concaténer un champ enfant sur le parent en utilisant un séparateur donné  
**Exemple: Remonter le nom de tous les contacts d'un compte séparés par des tirets**
```
RollupHelper.Rollup concatRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c, RollupHelper.Aggregation.CONCAT, MonObjetEnfant__c.ChampEnfantAconcatener__c, 'Separateur', 'ChampDeLobjetEnfantSurLequelTrierLesEnfants');
rolls.addRollup(concatRollup);
```
**Exemple :**
```
RollupHelper.Rollup concatRollup = new RollupHelper.Rollup(Account.NomsDesContacts__c, RollupHelper.Aggregation.CONCAT, Contact.Name, ' - ', 'Name');
```
*(On peut mettre "NomDuChamp DESC" en dernier paramètre pour faire un tri décroissant)*

## 4. Ajouter des filtres (Rollup Filters)
Vous pouvez ajouter autant de filtres que vous voulez sur l'objet enfant.
Liste de opérateurs disponibles pour les filtres :

- EQ
- NOT_EQ
- SUP
- SUP_EQ
- INF
- INF_EQ
- CONTAINS
- NOT_CONTAINS
- CONTAINS_IGNORE_CASE
- NOT_CONTAINS_IGNORE_CASE
- STARTS_WITH
- NOT_STARTS_WITH
- STARTS_WITH_IGNORE_CASE
- NOT_STARTS_WITH_IGNORE_CASE   

Les conditions doivent être ajoutées sur l'objet RollupHelper.Rollup, avant l'appel du .addRollup(...)

**Exemple: sur un COUNT :**
```
RollupHelper.Rollup countRollup = new RollupHelper.Rollup(MonObjetParent__c.ChampRollupSurLeParent__c);
countRollup.addFilter(MonObjetEnfant__c.MonChampSurLequelFiltrer__c, RollupHelper.Operator.EQ, valeurDuFiltre);
rolls.addRollup(countRollup);
```
**Autres exemples :**
```
monRollup.addFilter(Project__c.IsActive__c, RollupHelper.Operator.EQ, true);

monRollup.addFilter(Project__c.TotalTime__c, RollupHelper.Operator.SUP_EQ, 10);

monRollup.addFilter(Project__c.Name, RollupHelper.Operator.STARTS_WITH, 'GAC');

monRollup.addFilter(Project__c.StartDate__c, RollupHelper.Operator.INF, Date.newInstance(2016, 1, 1));
```
Si vous ajoutez plusieurs filtres à un Rollup, ceux-ci s'additionneront (AND).  
Si vous souhaitez utiliser des OR, vous pouvez toujours utiliser un champ formule Checkbox et ajouter un filtre sur ce champ ;)

## 5. Utilisation du rollup dans le cas d'update
Lors de la modification d'un enregistrement, si le champ parent du rollup est modifié il faut faire un appel sur l'ancien record et le nouveau:
```
//instanciate list with false by default
List<Boolean> useOldMapParams = new List<Boolean>{false};
if(Trigger.isUpdate){
    //if trigger is Update, we use the old map also to udpate the previous parent
  useOldMapParams.add(true);
}

for(Boolean useOldMap : useOldMapParams){
    RollupHelper rolls = new RollupHelper(Dossier__c.Compte__c, useOldMap);

    RollupHelper.Rollup countRollup = new RollupHelper.Rollup(Account.TECHCompteNBOuvert__c);
    countRollup.addFilter(Dossier__c.Statut__c, RollupHelper.Operator.NOT_EQ, 'Annulee');
    rolls.addRollup(countRollup);

    rolls.process();
}
```
