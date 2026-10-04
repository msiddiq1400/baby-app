"""Generates app/assets/foods.json: the solids guide (foods, rules, myths).

Sources: NHS "Your baby's first solid foods" and "Foods to avoid giving
babies and young children"; WHO infant and young child feeding guidance.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from recipes import RECIPES, VEG_FIRST  # noqa: E402

OUT = sys.argv[1]


def T(en, ur, rl):
    return {"en": en, "ur": ur, "ur_Latn": rl}


def food(id, cat, months, allergen, choking, name, prep):
    return {"id": id, "category": cat, "fromMonths": months, "allergen": allergen,
            "choking": choking, "name": name, "prep": prep}


foods = [
    # Fruit
    food("banana", "fruit", 6, None, False, T("Banana", "کیلا", "Kela"),
         T("Mash ripe banana with a fork. From about 9 months, offer soft finger-sized pieces.",
           "پکا ہوا کیلا کانٹے سے مسل کر دیں۔ تقریباً 9 ماہ سے نرم، انگلی جتنے ٹکڑے دیں۔",
           "Pakka kela kaante se masal kar dein. Taqreeban 9 mahine se naram, ungli jitne tukre dein.")),
    food("apple", "fruit", 6, None, True, T("Apple", "سیب", "Saib"),
         T("Cook until soft, then mash or purée. Don't give raw hard pieces (choking risk); grate it finely instead.",
           "نرم ہونے تک پکائیں، پھر مسل لیں یا پیوری بنائیں۔ کچے سخت ٹکڑے نہ دیں (گلے میں پھنسنے کا خطرہ)؛ اس کے بجائے باریک کدوکش کریں۔",
           "Naram hone tak pakayein, phir masal lein ya puree banayein. Kachay sakht tukre na dein (gale mein phansne ka khatra); is ke bajaye bareek kaddukash karein.")),
    food("pear", "fruit", 6, None, False, T("Pear", "ناشپاتی", "Nashpati"),
         T("Mash very ripe, soft pears; cook firmer pears first.",
           "بہت پکی اور نرم ناشپاتی مسل کر دیں؛ سخت ناشپاتی پہلے پکا لیں۔",
           "Bohat pakki aur naram nashpati masal kar dein; sakht nashpati pehle paka lein.")),
    food("mango", "fruit", 6, None, False, T("Mango", "آم", "Aam"),
         T("Mash ripe mango, or give a large peeled strip to hold and suck. Remove the stone.",
           "پکا آم مسل کر دیں، یا چھلا ہوا بڑا ٹکڑا پکڑنے اور چوسنے کے لیے دیں۔ گٹھلی نکال دیں۔",
           "Pakka aam masal kar dein, ya chhila hua bara tukra pakarne aur choosne ke liye dein. Guthli nikal dein.")),
    food("papaya", "fruit", 6, None, False, T("Papaya", "پپیتا", "Papita"),
         T("Remove the skin and seeds, then mash ripe papaya.",
           "چھلکا اور بیج نکال کر پکا پپیتا مسل کر دیں۔",
           "Chhilka aur beej nikal kar pakka papita masal kar dein.")),
    food("chikoo", "fruit", 6, None, True, T("Chikoo (sapodilla)", "چیکو", "Chikoo"),
         T("Remove the skin and the hard black seeds, then mash.",
           "چھلکا اور سخت کالے بیج نکال کر مسل لیں۔",
           "Chhilka aur sakht kaale beej nikal kar masal lein.")),
    food("grapes", "fruit", 6, None, True, T("Grapes", "انگور", "Angoor"),
         T("Always cut into quarters lengthways and remove seeds. Never give whole grapes.",
           "ہمیشہ لمبائی میں چار ٹکڑے کریں اور بیج نکال دیں۔ ثابت انگور کبھی نہ دیں۔",
           "Hamesha lambai mein chaar tukre karein aur beej nikal dein. Saabit angoor kabhi na dein.")),
    food("watermelon", "fruit", 6, None, False, T("Watermelon", "تربوز", "Tarbooz"),
         T("Remove all seeds and offer soft pieces or mash.",
           "سارے بیج نکال کر نرم ٹکڑے دیں یا مسل لیں۔",
           "Saare beej nikal kar naram tukre dein ya masal lein.")),
    # Vegetables
    food("carrot", "vegetable", 6, None, True, T("Carrot", "گاجر", "Gajar"),
         T("Steam or boil until very soft, then mash or offer soft cooked sticks. Never raw pieces.",
           "بھاپ یا ابال کر بہت نرم کریں، پھر مسل لیں یا نرم پکی ہوئی ڈنڈیاں دیں۔ کچے ٹکڑے کبھی نہ دیں۔",
           "Bhaap ya ubaal kar bohat naram karein, phir masal lein ya naram paki hui dandiyan dein. Kachay tukre kabhi na dein.")),
    food("potato", "vegetable", 6, None, False, T("Potato", "آلو", "Aloo"),
         T("Boil and mash with a little breast milk or formula. No salt.",
           "ابال کر تھوڑے ماں کے دودھ یا فارمولا کے ساتھ مسل لیں۔ نمک نہ ڈالیں۔",
           "Ubaal kar thore maa ke doodh ya formula ke saath masal lein. Namak na daalein.")),
    food("sweet_potato", "vegetable", 6, None, False, T("Sweet potato", "شکر قندی", "Shakarkandi"),
         T("Boil or bake until soft; mash, or offer soft wedges.",
           "ابال کر یا بیک کر کے نرم کریں؛ مسل لیں یا نرم ٹکڑے دیں۔",
           "Ubaal kar ya bake kar ke naram karein; masal lein ya naram tukre dein.")),
    food("pumpkin", "vegetable", 6, None, False, T("Pumpkin", "کدو", "Kaddu"),
         T("Cook until soft and mash.",
           "نرم ہونے تک پکا کر مسل لیں۔",
           "Naram hone tak paka kar masal lein.")),
    food("bottle_gourd", "vegetable", 6, None, False, T("Bottle gourd (lauki)", "لوکی / گھیا", "Lauki / Ghiya"),
         T("Peel, remove the seeds, cook until soft and mash. Its mild taste makes it a good early food.",
           "چھیل کر بیج نکالیں، نرم ہونے تک پکا کر مسل لیں۔ ہلکا ذائقہ ہونے کی وجہ سے شروع میں اچھی غذا ہے۔",
           "Chheel kar beej nikalein, naram hone tak paka kar masal lein. Halka zaiqa hone ki wajah se shuru mein achhi ghiza hai.")),
    food("spinach", "vegetable", 6, None, False, T("Spinach", "پالک", "Palak"),
         T("Cook and blend finely, or mix into daal or khichdi.",
           "پکا کر باریک پیس لیں، یا دال یا کھچڑی میں ملا دیں۔",
           "Paka kar bareek pees lein, ya daal ya khichri mein mila dein.")),
    food("cauliflower", "vegetable", 6, None, False, T("Cauliflower / broccoli", "گوبھی / بروکلی", "Gobhi / Broccoli"),
         T("Steam the florets until soft; mash, or give them as soft finger food.",
           "پھولوں کو بھاپ میں نرم کریں؛ مسل لیں یا نرم ٹکڑوں کی صورت میں ہاتھ میں پکڑنے کو دیں۔",
           "Phoolon ko bhaap mein naram karein; masal lein ya naram tukron ki soorat mein haath mein pakarne ko dein.")),
    food("peas", "vegetable", 6, None, True, T("Peas", "مٹر", "Matar"),
         T("Cook and mash, or flatten each pea. Whole round peas can choke young babies.",
           "پکا کر مسل لیں یا ہر دانہ دبا کر چپٹا کر دیں۔ ثابت گول دانے چھوٹے بچوں کے گلے میں پھنس سکتے ہیں۔",
           "Paka kar masal lein ya har daana daba kar chapta kar dein. Saabit gol daane chhote bachon ke gale mein phans sakte hain.")),
    # Grains
    food("rice", "grain", 6, None, False, T("Rice", "چاول", "Chawal"),
         T("Cook soft and mash, or make khichdi. No added sugar or salt.",
           "نرم پکا کر مسل لیں یا کھچڑی بنائیں۔ چینی یا نمک نہ ڈالیں۔",
           "Naram paka kar masal lein ya khichri banayein. Cheeni ya namak na daalein.")),
    food("khichdi", "grain", 6, None, False, T("Khichdi (rice + moong daal)", "کھچڑی (چاول + مونگ دال)", "Khichri (chawal + moong daal)"),
         T("Cook rice and moong daal very soft with vegetables; mash for younger babies. No salt.",
           "چاول اور مونگ دال سبزیوں کے ساتھ بہت نرم پکائیں؛ چھوٹے بچوں کے لیے مسل لیں۔ نمک نہ ڈالیں۔",
           "Chawal aur moong daal sabziyon ke saath bohat naram pakayein; chhote bachon ke liye masal lein. Namak na daalein.")),
    food("daliya", "grain", 6, "wheat", False, T("Daliya (broken wheat)", "دلیہ", "Daliya"),
         T("Cook with water or breast milk until very soft. No sugar; sweeten with mashed fruit if needed.",
           "پانی یا ماں کے دودھ میں بہت نرم پکائیں۔ چینی نہ ڈالیں؛ ضرورت ہو تو مسلا ہوا پھل ملا دیں۔",
           "Paani ya maa ke doodh mein bohat naram pakayein. Cheeni na daalein; zaroorat ho to masla hua phal mila dein.")),
    food("suji", "grain", 6, "wheat", False, T("Suji (semolina)", "سوجی", "Suji"),
         T("Cook into a smooth porridge. No added sugar; sweeten with mashed fruit instead.",
           "ہموار دلیہ کی طرح پکائیں۔ چینی نہ ڈالیں؛ اس کے بجائے مسلا ہوا پھل ملائیں۔",
           "Hamwar daliye ki tarah pakayein. Cheeni na daalein; is ke bajaye masla hua phal milayein.")),
    food("oats", "grain", 6, None, False, T("Oats", "جئی", "Jai (oats)"),
         T("Cook until soft; blend for younger babies.",
           "نرم ہونے تک پکائیں؛ چھوٹے بچوں کے لیے پیس لیں۔",
           "Naram hone tak pakayein; chhote bachon ke liye pees lein.")),
    food("roti", "grain", 6, "wheat", False, T("Roti", "روٹی", "Roti"),
         T("Soak small pieces of soft roti in daal or milk. From about 9 months, offer soft strips to hold.",
           "نرم روٹی کے چھوٹے ٹکڑے دال یا دودھ میں بھگو کر دیں۔ تقریباً 9 ماہ سے نرم پٹیاں پکڑنے کو دیں۔",
           "Naram roti ke chhote tukre daal ya doodh mein bhigo kar dein. Taqreeban 9 mahine se naram pattiyan pakarne ko dein.")),
    # Legumes
    food("moong_daal", "legume", 6, None, False, T("Moong daal", "مونگ کی دال", "Moong ki daal"),
         T("Cook until very soft and mash. A good early source of protein and iron. No salt.",
           "بہت نرم پکا کر مسل لیں۔ پروٹین اور آئرن کا اچھا ذریعہ ہے۔ نمک نہ ڈالیں۔",
           "Bohat naram paka kar masal lein. Protein aur iron ka achha zariya hai. Namak na daalein.")),
    food("masoor_daal", "legume", 6, None, False, T("Masoor daal", "مسور کی دال", "Masoor ki daal"),
         T("Cook until very soft and mash; mix with rice or vegetables. No salt.",
           "بہت نرم پکا کر مسل لیں؛ چاول یا سبزی کے ساتھ ملائیں۔ نمک نہ ڈالیں۔",
           "Bohat naram paka kar masal lein; chawal ya sabzi ke saath milayein. Namak na daalein.")),
    food("chickpeas", "legume", 6, None, True, T("Chickpeas (chanay)", "چنے", "Chanay"),
         T("Cook well and mash or flatten. Never give them whole.",
           "اچھی طرح پکا کر مسل لیں یا دبا کر چپٹا کر دیں۔ ثابت کبھی نہ دیں۔",
           "Achhi tarah paka kar masal lein ya daba kar chapta kar dein. Saabit kabhi na dein.")),
    # Protein
    food("chicken", "protein", 6, None, False, T("Chicken", "مرغی", "Murghi"),
         T("Cook thoroughly, then mince, shred finely or blend with some cooking water. Remove all bones.",
           "اچھی طرح پکائیں، پھر قیمہ کریں، باریک ریشے کریں یا یخنی کے ساتھ پیس لیں۔ تمام ہڈیاں نکال دیں۔",
           "Achhi tarah pakayein, phir qeema karein, bareek reshay karein ya yakhni ke saath pees lein. Tamam haddiyan nikal dein.")),
    food("qeema", "protein", 6, None, False, T("Qeema (minced meat)", "قیمہ", "Qeema"),
         T("Cook minced mutton or beef thoroughly and mash with vegetables. A good source of iron.",
           "بکرے یا گائے کا قیمہ اچھی طرح پکا کر سبزیوں کے ساتھ مسل لیں۔ آئرن کا اچھا ذریعہ ہے۔",
           "Bakre ya gaaye ka qeema achhi tarah paka kar sabziyon ke saath masal lein. Iron ka achha zariya hai.")),
    food("egg", "protein", 6, "egg", False, T("Egg", "انڈا", "Anda"),
         T("Cook until both the white and the yolk are solid. Mash hard-boiled egg, or give strips of omelette.",
           "سفیدی اور زردی دونوں پوری طرح پکنے تک پکائیں۔ ابلا ہوا انڈا مسل لیں یا آملیٹ کی پٹیاں دیں۔",
           "Safedi aur zardi dono poori tarah pakne tak pakayein. Ubla hua anda masal lein ya omelette ki pattiyan dein.")),
    food("fish", "protein", 6, "fish", True, T("Fish", "مچھلی", "Machli"),
         T("Cook thoroughly and remove every bone; flake and mash. Avoid shark, swordfish and marlin.",
           "اچھی طرح پکائیں اور ہر کانٹا نکال دیں؛ ٹکڑے کر کے مسل لیں۔ شارک، سورڈ فش اور مارلن نہ دیں۔",
           "Achhi tarah pakayein aur har kaanta nikal dein; tukre kar ke masal lein. Shark, swordfish aur marlin na dein.")),
    # Dairy
    food("yogurt", "dairy", 6, "milk", False, T("Yogurt (dahi)", "دہی", "Dahi"),
         T("Plain, full-fat yogurt with no added sugar.",
           "سادہ، پوری چکنائی والا دہی، بغیر چینی کے۔",
           "Saada, poori chiknai wala dahi, baghair cheeni ke.")),
    food("paneer", "dairy", 6, "milk", False, T("Paneer / cheese", "پنیر", "Paneer"),
         T("Pasteurised, full-fat paneer or cheese, grated or in soft small pieces.",
           "پیسچرائزڈ، پوری چکنائی والا پنیر، کدوکش کر کے یا نرم چھوٹے ٹکڑوں میں۔",
           "Pasteurized, poori chiknai wala paneer, kaddukash kar ke ya naram chhote tukron mein.")),
    food("cows_milk", "dairy", 6, "milk", False, T("Cow's milk (in cooking)", "گائے کا دودھ (کھانے میں)", "Gaaye ka doodh (khane mein)"),
         T("Fine in cooking, for example in daliya, from about 6 months, but not as the main drink until 12 months.",
           "تقریباً 6 ماہ سے کھانے میں (مثلاً دلیے میں) ٹھیک ہے، لیکن 12 ماہ تک اسے اہم مشروب کے طور پر نہ دیں۔",
           "Taqreeban 6 mahine se khane mein (maslan daliye mein) theek hai, lekin 12 mahine tak isay ahem mashroob ke taur par na dein.")),
    # Nuts and seeds
    food("peanut", "nut", 6, "peanut", True, T("Peanut (smooth paste)", "مونگ پھلی (ہموار پیسٹ)", "Moongphali (hamwar paste)"),
         T("Smooth peanut butter thinned with water or stirred into porridge. Never whole or chopped peanuts: no whole nuts before 5 years.",
           "ہموار پینٹ بٹر پانی سے پتلا کر کے یا دلیے میں ملا کر دیں۔ ثابت یا کٹی مونگ پھلی کبھی نہیں: 5 سال سے پہلے ثابت میوے نہ دیں۔",
           "Hamwar peanut butter paani se patla kar ke ya daliye mein mila kar dein. Saabit ya kati moongphali kabhi nahi: 5 saal se pehle saabit mewe na dein.")),
    food("almond", "nut", 6, "tree_nut", True, T("Almonds and other nuts (ground)", "بادام اور دیگر میوے (پسے ہوئے)", "Badam aur deegar mewe (pise hue)"),
         T("Finely ground into porridge, or as a smooth nut butter. Never whole or chopped nuts.",
           "باریک پیس کر دلیے میں ملائیں، یا ہموار نٹ بٹر کی صورت میں۔ ثابت یا کٹے میوے کبھی نہ دیں۔",
           "Bareek pees kar daliye mein milayein, ya hamwar nut butter ki soorat mein. Saabit ya kate mewe kabhi na dein.")),
    food("sesame", "nut", 6, "sesame", False, T("Sesame (til)", "تل", "Til"),
         T("Smooth tahini (sesame paste) stirred into food.",
           "ہموار تاہینی (تل کا پیسٹ) کھانے میں ملا کر دیں۔",
           "Hamwar tahini (til ka paste) khane mein mila kar dein.")),
    # Not before 12 months
    food("honey", "other", 12, None, False, T("Honey (not before 1 year)", "شہد (1 سال سے پہلے نہیں)", "Shehad (1 saal se pehle nahi)"),
         T("Don't give honey before 12 months, not even a little in ghutti: it can contain bacteria that cause infant botulism, a serious illness.",
           "12 ماہ سے پہلے شہد نہ دیں، گھٹی میں تھوڑا سا بھی نہیں: اس میں ایسے جراثیم ہو سکتے ہیں جو بچوں میں بوٹولزم نامی سنگین بیماری کا سبب بنتے ہیں۔",
           "12 mahine se pehle shehad na dein, ghutti mein thora sa bhi nahi: is mein aise jaraseem ho sakte hain jo bachon mein botulism naami sangeen beemari ka sabab bante hain.")),
]

allergens = {
    "egg": T("Egg", "انڈا", "Anda"),
    "milk": T("Milk", "دودھ", "Doodh"),
    "peanut": T("Peanut", "مونگ پھلی", "Moongphali"),
    "tree_nut": T("Tree nuts", "میوے", "Mewe"),
    "sesame": T("Sesame", "تل", "Til"),
    "wheat": T("Wheat", "گندم", "Gandum"),
    "fish": T("Fish", "مچھلی", "Machli"),
}

guides = {
    "vegFirst": VEG_FIRST,
    "readiness": T(
        "Most babies are ready around 6 months, when they can do all three: stay sitting with a steady head; look at food, pick it up and put it in their mouth; and swallow food rather than push it back out. Chewing fists, waking at night or wanting extra milk are normal and are not signs of readiness.",
        "زیادہ تر بچے تقریباً 6 ماہ پر تیار ہوتے ہیں، جب وہ یہ تینوں کام کر سکیں: سر سنبھال کر بیٹھے رہنا؛ کھانا دیکھ کر اٹھانا اور منہ میں ڈالنا؛ اور کھانا باہر دھکیلنے کے بجائے نگلنا۔ مٹھیاں چبانا، رات کو جاگنا یا زیادہ دودھ مانگنا عام بات ہے اور تیاری کی نشانیاں نہیں۔",
        "Zyada tar bachay taqreeban 6 mahine par tayyar hote hain, jab woh yeh teenon kaam kar sakein: sar sambhal kar baithe rehna; khana dekh kar uthana aur munh mein daalna; aur khana bahar dhakelne ke bajaye nigalna. Mutthiyan chabana, raat ko jaagna ya zyada doodh maangna aam baat hai aur tayyari ki nishaniyan nahi."),
    "stages": [
        {"months": "6", "text": T(
            "Around 6 months: smooth or mashed foods, or soft finger foods. Start with a few spoons once a day; milk is still the main food.",
            "تقریباً 6 ماہ: ہموار یا مسلا ہوا کھانا، یا نرم ٹکڑے۔ دن میں ایک بار چند چمچ سے شروع کریں؛ دودھ اب بھی اصل غذا ہے۔",
            "Taqreeban 6 mahine: hamwar ya masla hua khana, ya naram tukre. Din mein ek baar chand chamach se shuru karein; doodh ab bhi asal ghiza hai.")},
        {"months": "7-9", "text": T(
            "7 to 9 months: mashed, lumpy and finger foods, building up to 3 meals a day. Include iron-rich foods such as meat, fish, eggs and daal.",
            "7 سے 9 ماہ: مسلا ہوا، دانے دار اور ہاتھ میں پکڑنے والا کھانا، آہستہ آہستہ دن میں 3 کھانوں تک۔ آئرن والی غذائیں شامل کریں جیسے گوشت، مچھلی، انڈا اور دال۔",
            "7 se 9 mahine: masla hua, daane daar aur haath mein pakarne wala khana, aahista aahista din mein 3 khanon tak. Iron wali ghizayein shamil karein jaise gosht, machli, anda aur daal.")},
        {"months": "10-12", "text": T(
            "10 to 12 months: 3 meals a day with chopped family food and a wider range of finger foods, still without added salt or sugar.",
            "10 سے 12 ماہ: دن میں 3 کھانے، گھر کا کٹا ہوا کھانا اور مختلف ہاتھ میں پکڑنے والی غذائیں، اب بھی نمک یا چینی کے بغیر۔",
            "10 se 12 mahine: din mein 3 khane, ghar ka kata hua khana aur mukhtalif haath mein pakarne wali ghizayein, ab bhi namak ya cheeni ke baghair.")},
    ],
    "rules": [
        T("No added salt or sugar before 12 months (so no namkeen snacks, biscuits or sweet drinks).",
          "12 ماہ سے پہلے نمک یا چینی نہ ڈالیں (یعنی نمکین، بسکٹ یا میٹھے مشروبات نہیں)۔",
          "12 mahine se pehle namak ya cheeni na daalein (yani namkeen, biscuit ya meethe mashroobat nahi)."),
        T("No honey before 12 months.", "12 ماہ سے پہلے شہد نہیں۔", "12 mahine se pehle shehad nahi."),
        T("No whole nuts before 5 years; use smooth nut butters or finely ground nuts.",
          "5 سال سے پہلے ثابت میوے نہیں؛ ہموار نٹ بٹر یا باریک پسے میوے استعمال کریں۔",
          "5 saal se pehle saabit mewe nahi; hamwar nut butter ya bareek pise mewe istemal karein."),
        T("Cut small round foods (grapes, cherry tomatoes) into quarters, and remove seeds, stones and bones.",
          "چھوٹی گول چیزیں (انگور، چھوٹے ٹماٹر) چار ٹکڑوں میں کاٹیں، اور بیج، گٹھلیاں اور ہڈیاں نکال دیں۔",
          "Chhoti gol cheezein (angoor, chhote tamatar) chaar tukron mein kaatein, aur beej, guthliyan aur haddiyan nikal dein."),
        T("Breast milk or formula stays the main drink until 12 months. Offer sips of water in an open cup with meals from 6 months.",
          "12 ماہ تک ماں کا دودھ یا فارمولا ہی اصل مشروب ہے۔ 6 ماہ سے کھانے کے ساتھ کھلے کپ میں پانی کے گھونٹ دیں۔",
          "12 mahine tak maa ka doodh ya formula hi asal mashroob hai. 6 mahine se khane ke saath khule cup mein paani ke ghoont dein."),
        T("Always stay with your baby while they eat, sitting upright. Gagging is normal while learning; choking is silent, so watch closely.",
          "کھاتے وقت ہمیشہ بچے کے ساتھ رہیں اور اسے سیدھا بٹھائیں۔ سیکھتے ہوئے ابکائی آنا عام ہے؛ گلا بند ہونا خاموش ہوتا ہے، اس لیے دھیان سے دیکھیں۔",
          "Khate waqt hamesha bache ke saath rahein aur usay seedha bithayein. Seekhte hue abkai aana aam hai; gala band hona khamosh hota hai, is liye dhiyan se dekhein."),
    ],
    "allergenAdvice": T(
        "Common allergens (egg, milk, peanut, nuts, sesame, wheat, fish) can be given from around 6 months: one new one at a time, in a small amount, so you can spot any reaction. Once your baby has had one without a problem, keep it in their diet regularly.",
        "عام الرجی والی غذائیں (انڈا، دودھ، مونگ پھلی، میوے، تل، گندم، مچھلی) تقریباً 6 ماہ سے دی جا سکتی ہیں: ایک وقت میں ایک نئی، تھوڑی مقدار میں، تاکہ کوئی ردِعمل پہچانا جا سکے۔ اگر بچے کو کوئی مسئلہ نہ ہو تو اسے باقاعدگی سے کھانے میں شامل رکھیں۔",
        "Aam allergy wali ghizayein (anda, doodh, moongphali, mewe, til, gandum, machli) taqreeban 6 mahine se di ja sakti hain: ek waqt mein ek nayi, thori miqdar mein, taake koi rad-e-amal pehchana ja sake. Agar bache ko koi masla na ho to isay baqaidgi se khane mein shamil rakhein."),
    "reactionSigns": T(
        "Possible allergic reaction: rash or hives, itching, swelling of the lips, face or eyes, vomiting, or diarrhoea soon after eating. Stop that food and talk to your doctor. EMERGENCY, call {emergency} straight away: difficulty breathing, wheezing, swelling of the tongue or throat, or the baby becoming floppy, pale or unresponsive.",
        "ممکنہ الرجی ردِعمل: دانے یا چھپاکی، خارش، ہونٹوں، چہرے یا آنکھوں پر سوجن، کھانے کے فوراً بعد الٹی یا دست۔ وہ غذا روک دیں اور ڈاکٹر سے بات کریں۔ ایمرجنسی، فوراً {emergency} پر کال کریں: سانس لینے میں مشکل، سیٹی جیسی آواز، زبان یا گلے میں سوجن، یا بچہ ڈھیلا، زرد یا بے سدھ ہو جائے۔",
        "Mumkina allergy rad-e-amal: daane ya chhapaki, kharish, honton, chehre ya aankhon par soojan, khane ke foran baad ulti ya dast. Woh ghiza rok dein aur doctor se baat karein. EMERGENCY, foran {emergency} par call karein: saans lene mein mushkil, seeti jaisi awaaz, zabaan ya gale mein soojan, ya bacha dheela, zard ya be-sudh ho jaye."),
    "myths": [
        {"belief": T("Give ghutti with honey to newborns.", "نوزائیدہ کو شہد والی گھٹی دیں۔", "Nauzaida ko shehad wali ghutti dein."),
         "evidence": T("Honey is not safe before 12 months because of the risk of infant botulism. Newborns need only breast milk (or formula).",
                       "بوٹولزم کے خطرے کی وجہ سے 12 ماہ سے پہلے شہد محفوظ نہیں۔ نوزائیدہ کو صرف ماں کا دودھ (یا فارمولا) چاہیے۔",
                       "Botulism ke khatre ki wajah se 12 mahine se pehle shehad mehfooz nahi. Nauzaida ko sirf maa ka doodh (ya formula) chahiye.")},
        {"belief": T("Babies need extra water in the heat, even under 6 months.", "گرمی میں 6 ماہ سے کم بچوں کو بھی اضافی پانی چاہیے۔", "Garmi mein 6 mahine se kam bachon ko bhi izafi paani chahiye."),
         "evidence": T("WHO: babies under 6 months who are exclusively breastfed don't need water, even in hot weather. Breastfeed more often instead. Formula-fed babies may need a little cooled boiled water; ask your doctor.",
                       "عالمی ادارہ صحت: صرف ماں کا دودھ پینے والے 6 ماہ سے کم بچوں کو گرمی میں بھی پانی کی ضرورت نہیں۔ اس کے بجائے زیادہ بار دودھ پلائیں۔ فارمولا پینے والے بچوں کو تھوڑا ابلا ہوا ٹھنڈا پانی دینا پڑ سکتا ہے؛ ڈاکٹر سے پوچھیں۔",
                       "Aalmi idara-e-sehat: sirf maa ka doodh peene wale 6 mahine se kam bachon ko garmi mein bhi paani ki zaroorat nahi. Is ke bajaye zyada baar doodh pilayein. Formula peene wale bachon ko thora ubla hua thanda paani dena par sakta hai; doctor se poochein.")},
        {"belief": T("A little chai is fine for babies.", "بچوں کے لیے تھوڑی سی چائے ٹھیک ہے۔", "Bachon ke liye thori si chai theek hai."),
         "evidence": T("Tea isn't suitable for babies or young children: it contains caffeine and reduces how much iron they absorb from food.",
                       "چائے بچوں کے لیے مناسب نہیں: اس میں کیفین ہوتی ہے اور یہ کھانے سے آئرن جذب ہونے کو کم کرتی ہے۔",
                       "Chai bachon ke liye munasib nahi: is mein caffeine hoti hai aur yeh khane se iron jazb hone ko kam karti hai.")},
        {"belief": T("Starting cereal early helps babies sleep through the night.", "جلدی دلیہ شروع کرنے سے بچہ رات بھر سوتا ہے۔", "Jaldi daliya shuru karne se bacha raat bhar sota hai."),
         "evidence": T("There's no good evidence for this. Solids are recommended from around 6 months, when your baby shows the signs of readiness.",
                       "اس کا کوئی ٹھوس ثبوت نہیں۔ ٹھوس غذا تقریباً 6 ماہ سے تجویز کی جاتی ہے، جب بچے میں تیاری کی نشانیاں ہوں۔",
                       "Is ka koi thos saboot nahi. Thos ghiza taqreeban 6 mahine se tajweez ki jati hai, jab bache mein tayyari ki nishaniyan hon.")},
        {"belief": T("Wait until later to give eggs or peanuts, to prevent allergy.", "الرجی سے بچنے کے لیے انڈا یا مونگ پھلی دیر سے دیں۔", "Allergy se bachne ke liye anda ya moongphali der se dein."),
         "evidence": T("Delaying doesn't prevent allergy. Allergenic foods can be introduced from around 6 months, one at a time. If your baby already has eczema or a food allergy, ask your doctor first.",
                       "دیر کرنے سے الرجی نہیں رکتی۔ الرجی والی غذائیں تقریباً 6 ماہ سے، ایک ایک کر کے دی جا سکتی ہیں۔ اگر بچے کو پہلے سے ایگزیما یا کسی غذا سے الرجی ہو تو پہلے ڈاکٹر سے پوچھیں۔",
                       "Der karne se allergy nahi rukti. Allergy wali ghizayein taqreeban 6 mahine se, ek ek kar ke di ja sakti hain. Agar bache ko pehle se eczema ya kisi ghiza se allergy ho to pehle doctor se poochein.")},
    ],
    "sources": "NHS (Your baby's first solid foods; Foods to avoid giving babies and young children), WHO infant and young child feeding guidance.",
}

with open(OUT, "w", encoding="utf-8") as f:
    json.dump({"foods": foods, "allergens": allergens, "guides": guides, "recipes": RECIPES}, f, ensure_ascii=False, indent=1)
print(len(foods), "foods and", len(RECIPES), "recipes written to", OUT)
