import json
import xmltodict

xml = open("data_preload/annotation/durgbank_5_1_12_full_database.xml").read()
json_file = "data_preload/annotation/drugbank.json"
convertJson = xmltodict.parse(xml, encoding='utf-8')
jsonStr = json.dumps(convertJson, indent=1)

with open(json_file, 'w+', encoding='utf-8') as f:
    f.write(jsonStr)

with open(json_file, 'r') as f:
    data = json.load(f)
drugs = data['drugbank']['drug']

file = open('data_preload/annotation/drugbankitem.csv', 'w')

for drug in drugs:
    try:
        drug_id = drug['drugbank-id'][0]['#text']
    except Exception as e:
        drug_id = drug['drugbank-id']['#text']
        
    drug_name = drug['name']
    drug_type = drug['@type']

    if isinstance(drug["groups"]["group"], list):
        drug_status = ",".join(drug["groups"]["group"])
    else:
        drug_status = drug["groups"]["group"]
    
    
    drug_indication = str(drug['indication']).replace('\n', '').replace('\t', '').replace('\r', '')

    item = '\t'.join([drug_id, drug_name, drug_type,drug_status,drug_indication ])
    file.writelines(item + '\n')

file.close()
