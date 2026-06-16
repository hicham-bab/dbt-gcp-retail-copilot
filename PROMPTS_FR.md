# Prompts de démo — GreenField Retail sur BigQuery

## 1. Migration de la procédure stockée

```text
Lis `legacy/sp_customer_ltv.sql` et explique clairement ce que cette procédure calcule, quelle est la granularité de la table produite, et quelles règles métier elle applique.

Ensuite, inspecte les modèles existants dans `models/staging` et `models/intermediate`, puis crée un modèle dbt dans `models/marts/finance/mart_customer_ltv.sql` qui reproduit cette logique en utilisant `ref()` dès que possible au lieu de relire les tables brutes.

Conserve les mêmes colonnes de sortie et les mêmes règles métier que la procédure. Après l’avoir écrit, exécute la validation dbt la plus appropriée et corrige ce qui échoue.
```

## 2. Lineage / impact

```text
Montre comment `mart_customer_ltv` s’insère dans le projet : quelles sont ses dépendances amont, et qu’est-ce qui casserait en aval si on changeait sa granularité ou si on renomm ait la colonne `ltv_segment` ?

```

## 3. Documentation + tests

```text
Ajoute la documentation et les tests de données les plus utiles pour `mart_customer_ltv` dans `models/marts/finance/_finance_models.yml`.

Je veux :
- une description utile du modèle
- une description pour chaque colonne
- des tests `unique` et `not_null` sur la clé de granularité
- des tests `accepted_values` sur `ltv_segment` et `lifecycle_stage`
- un test de relation entre `customer_id` et `dim_customers`

Utilise la syntaxe dbt moderne, conserve les entrées déjà présentes dans le fichier, puis valide les changements.
```

## 4. Semantic layer + exports BigQuery

```text
Crée une couche sémantique sur `fct_orders` pour produire trois exports BigQuery destinés à une consommation externe.

Je veux exactement ces exports :
- `marts.core_order_metrics_daily`
- `marts.weekly_channel_region_performance`
- `marts.refund_and_fulfillment_monitoring`

Contraints-les ainsi :
- `marts.core_order_metrics_daily` : métriques de commandes au grain journalier
- `marts.weekly_channel_region_performance` : performance hebdomadaire par canal et région
- `marts.refund_and_fulfillment_monitoring` : suivi des remboursements et de l’exécution des commandes

Définis les entités, dimensions, métriques, saved queries et exports nécessaires dans la couche sémantique, en utilisant la syntaxe compatible avec ce projet, puis valide la configuration.
```
