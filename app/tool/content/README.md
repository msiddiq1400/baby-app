# App content

The solids guide and milestone checklists ship inside the app as JSON
(`assets/foods.json`, `assets/milestones.json`). Edit the Python scripts here,
not the JSON, then regenerate from the `app` folder:

```
python tool/content/make_foods.py assets/foods.json
python tool/content/make_milestones.py assets/milestones.json
```

Every text has `en`, `ur` (Urdu script) and `ur_Latn` (Roman Urdu).
Sources are noted at the top of each script. A pediatrician should review
changes before release.
