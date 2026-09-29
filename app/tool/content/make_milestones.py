"""Generates app/assets/milestones.json from the CDC "Learn the Signs. Act
Early." milestone checklists (2022 revision): what most babies (75% or more)
do by each age, plus a few of CDC's "what you can do" activities.
https://www.cdc.gov/act-early/milestones/
"""
import json
import sys

OUT = sys.argv[1]


def T(en, ur, rl):
    return {"en": en, "ur": ur, "ur_Latn": rl}


def m(id, area, text):
    return {"id": id, "area": area, "text": text}


ages = [
    {"months": 2, "milestones": [
        m("2m-calms", "social", T("Calms down when spoken to or picked up", "بات کرنے یا اٹھانے پر پرسکون ہو جاتا ہے", "Baat karne ya uthane par pursukoon ho jata hai")),
        m("2m-face", "social", T("Looks at your face", "آپ کے چہرے کو دیکھتا ہے", "Aap ke chehre ko dekhta hai")),
        m("2m-happy", "social", T("Seems happy to see you when you walk up", "آپ کے پاس آنے پر خوش لگتا ہے", "Aap ke paas aane par khush lagta hai")),
        m("2m-smiles", "social", T("Smiles when you talk to or smile at them", "آپ کے بات کرنے یا مسکرانے پر مسکراتا ہے", "Aap ke baat karne ya muskurane par muskurata hai")),
        m("2m-sounds", "language", T("Makes sounds other than crying", "رونے کے علاوہ آوازیں نکالتا ہے", "Rone ke ilawa awazein nikalta hai")),
        m("2m-loud", "language", T("Reacts to loud sounds", "تیز آوازوں پر ردِعمل دیتا ہے", "Tez awazon par rad-e-amal deta hai")),
        m("2m-watches", "cognitive", T("Watches you as you move", "آپ کو چلتے پھرتے دیکھتا ہے", "Aap ko chalte phirte dekhta hai")),
        m("2m-toy", "cognitive", T("Looks at a toy for several seconds", "کھلونے کو کئی سیکنڈ تک دیکھتا ہے", "Khilone ko kai second tak dekhta hai")),
        m("2m-head", "movement", T("Holds head up when on tummy", "پیٹ کے بل لیٹ کر سر اٹھاتا ہے", "Pait ke bal lait kar sar uthata hai")),
        m("2m-limbs", "movement", T("Moves both arms and both legs", "دونوں بازو اور دونوں ٹانگیں ہلاتا ہے", "Dono baazu aur dono tangein hilata hai")),
        m("2m-hands", "movement", T("Opens hands briefly", "کچھ دیر کے لیے مٹھیاں کھولتا ہے", "Kuch der ke liye mutthiyan kholta hai")),
    ], "tips": [
        T("Tummy time: lay your baby on their tummy while awake and watched, with a toy at eye level.", "پیٹ کے بل وقت: جاگتے ہوئے اور نگرانی میں بچے کو پیٹ کے بل لٹائیں، آنکھوں کی سطح پر کھلونا رکھیں۔", "Pait ke bal waqt: jaagte hue aur nigrani mein bache ko pait ke bal litayein, aankhon ki satah par khilona rakhein."),
        T("Talk, read and sing to your baby; copy their sounds.", "بچے سے باتیں کریں، پڑھ کر سنائیں اور گائیں؛ اس کی آوازوں کی نقل کریں۔", "Bache se baatein karein, parh kar sunayein aur gaayein; us ki awazon ki naqal karein."),
        T("Respond with smiles and excitement when your baby makes sounds.", "بچہ آواز نکالے تو مسکرا کر اور خوشی سے جواب دیں۔", "Bacha awaz nikale to muskura kar aur khushi se jawab dein."),
        T("Never shake a baby. If you feel upset, put them down safely and take a break.", "بچے کو کبھی نہ جھنجھوڑیں۔ غصہ آئے تو اسے محفوظ جگہ لٹا کر کچھ دیر وقفہ لیں۔", "Bache ko kabhi na jhanjhorein. Ghussa aaye to usay mehfooz jagah lita kar kuch der waqfa lein."),
    ]},
    {"months": 4, "milestones": [
        m("4m-smiles", "social", T("Smiles on their own to get your attention", "آپ کی توجہ کے لیے خود مسکراتا ہے", "Aap ki tawajjo ke liye khud muskurata hai")),
        m("4m-chuckles", "social", T("Chuckles when you try to make them laugh", "ہنسانے پر ہلکا سا کھلکھلاتا ہے", "Hansane par halka sa khilkhilata hai")),
        m("4m-attention", "social", T("Looks at you, moves or makes sounds to get your attention", "توجہ کے لیے آپ کو دیکھتا، ہلتا یا آواز نکالتا ہے", "Tawajjo ke liye aap ko dekhta, hilta ya awaz nikalta hai")),
        m("4m-coos", "language", T("Coos (\"oooo\", \"aahh\")", "غوں غاں کرتا ہے (\"اووو\"، \"آآہ\")", "Ghoon ghaan karta hai (\"oooo\", \"aahh\")")),
        m("4m-back", "language", T("Makes sounds back when you talk", "آپ کے بولنے پر جواب میں آوازیں نکالتا ہے", "Aap ke bolne par jawab mein awazein nikalta hai")),
        m("4m-turns", "language", T("Turns head towards the sound of your voice", "آپ کی آواز کی طرف سر گھماتا ہے", "Aap ki awaz ki taraf sar ghumata hai")),
        m("4m-mouth", "cognitive", T("If hungry, opens mouth when they see breast or bottle", "بھوک ہو تو دودھ یا بوتل دیکھ کر منہ کھولتا ہے", "Bhook ho to doodh ya bottle dekh kar munh kholta hai")),
        m("4m-hands", "cognitive", T("Looks at their hands with interest", "دلچسپی سے اپنے ہاتھوں کو دیکھتا ہے", "Dilchaspi se apne haathon ko dekhta hai")),
        m("4m-head", "movement", T("Holds head steady without support when held", "اٹھانے پر بغیر سہارے سر سیدھا رکھتا ہے", "Uthane par baghair sahare sar seedha rakhta hai")),
        m("4m-holds", "movement", T("Holds a toy when you put it in their hand", "ہاتھ میں دیا گیا کھلونا پکڑتا ہے", "Haath mein diya gaya khilona pakarta hai")),
        m("4m-swings", "movement", T("Swings an arm at toys", "کھلونوں کی طرف بازو مارتا ہے", "Khilonon ki taraf baazu maarta hai")),
        m("4m-mouthhands", "movement", T("Brings hands to mouth", "ہاتھ منہ تک لاتا ہے", "Haath munh tak laata hai")),
        m("4m-pushes", "movement", T("Pushes up onto elbows or forearms when on tummy", "پیٹ کے بل کہنیوں پر زور دے کر اوپر اٹھتا ہے", "Pait ke bal kohniyon par zor de kar upar uthta hai")),
    ], "tips": [
        T("Give safe toys to reach for, kick and put in the mouth, like rattles.", "پکڑنے، لات مارنے اور منہ میں ڈالنے کے لیے محفوظ کھلونے دیں، جیسے جھنجھنا۔", "Pakarne, laat maarne aur munh mein daalne ke liye mehfooz khilone dein, jaise jhunjhuna."),
        T("Take turns \"talking\": answer each sound your baby makes.", "باری باری \"بات\" کریں: بچے کی ہر آواز کا جواب دیں۔", "Baari baari \"baat\" karein: bache ki har awaz ka jawab dein."),
        T("Limit time in car seats and bouncers; give floor time every day.", "کار سیٹ اور جھولے میں کم وقت رکھیں؛ روزانہ فرش پر کھیلنے کا وقت دیں۔", "Car seat aur jhoole mein kam waqt rakhein; rozana farsh par khelne ka waqt dein."),
        T("No screens except video calls with family.", "خاندان کے ساتھ ویڈیو کال کے علاوہ کوئی اسکرین نہیں۔", "Family ke saath video call ke ilawa koi screen nahi."),
    ]},
    {"months": 6, "milestones": [
        m("6m-knows", "social", T("Knows familiar people", "جانے پہچانے لوگوں کو پہچانتا ہے", "Jaane pehchane logon ko pehchanta hai")),
        m("6m-mirror", "social", T("Likes to look at self in a mirror", "آئینے میں خود کو دیکھنا پسند کرتا ہے", "Aaine mein khud ko dekhna pasand karta hai")),
        m("6m-laughs", "social", T("Laughs", "ہنستا ہے", "Hansta hai")),
        m("6m-turns", "language", T("Takes turns making sounds with you", "آپ کے ساتھ باری باری آوازیں نکالتا ہے", "Aap ke saath baari baari awazein nikalta hai")),
        m("6m-raspberries", "language", T("Blows \"raspberries\"", "ہونٹوں سے پھرر کی آواز نکالتا ہے", "Honton se phurr ki awaz nikalta hai")),
        m("6m-squeals", "language", T("Makes squealing noises", "چیخ نما خوشی کی آوازیں نکالتا ہے", "Cheekh numa khushi ki awazein nikalta hai")),
        m("6m-mouth", "cognitive", T("Puts things in mouth to explore them", "چیزوں کو جاننے کے لیے منہ میں ڈالتا ہے", "Cheezon ko jaanne ke liye munh mein daalta hai")),
        m("6m-reaches", "cognitive", T("Reaches to grab a toy they want", "پسند کا کھلونا پکڑنے کے لیے ہاتھ بڑھاتا ہے", "Pasand ka khilona pakarne ke liye haath barhata hai")),
        m("6m-lips", "cognitive", T("Closes lips to show they don't want more food", "مزید کھانا نہ چاہے تو ہونٹ بند کر لیتا ہے", "Mazeed khana na chahe to hont band kar leta hai")),
        m("6m-rolls", "movement", T("Rolls from tummy to back", "پیٹ سے کمر کے بل پلٹتا ہے", "Pait se kamar ke bal palat-ta hai")),
        m("6m-straight", "movement", T("Pushes up with straight arms when on tummy", "پیٹ کے بل سیدھے بازوؤں پر اوپر اٹھتا ہے", "Pait ke bal seedhe baazuon par upar uthta hai")),
        m("6m-leans", "movement", T("Leans on hands to support themselves when sitting", "بیٹھتے وقت ہاتھوں کے سہارے ٹکتا ہے", "Baithte waqt haathon ke sahare tikta hai")),
    ], "tips": [
        T("Put toys just out of reach to encourage rolling and reaching.", "کھلونے تھوڑا دور رکھیں تاکہ بچہ پلٹنے اور ہاتھ بڑھانے کی کوشش کرے۔", "Khilone thora door rakhein taake bacha palatne aur haath barhane ki koshish kare."),
        T("Name the things you see together, and read picture books every day.", "جو چیزیں مل کر دیکھیں ان کے نام بتائیں، اور روزانہ تصویروں والی کتاب پڑھیں۔", "Jo cheezein mil kar dekhein un ke naam batayein, aur rozana tasveeron wali kitab parhein."),
        T("Hold your baby sitting up, supported, so they practise balance.", "بچے کو سہارا دے کر بٹھائیں تاکہ وہ توازن سیکھے۔", "Bache ko sahara de kar bithayein taake woh tawazun seekhe."),
        T("Ask your doctor about starting solids and avoiding choking hazards.", "ٹھوس غذا شروع کرنے اور گلے میں پھنسنے والی چیزوں کے بارے میں ڈاکٹر سے پوچھیں۔", "Thos ghiza shuru karne aur gale mein phansne wali cheezon ke baare mein doctor se poochein."),
    ]},
    {"months": 9, "milestones": [
        m("9m-strangers", "social", T("Is shy, clingy or fearful around strangers", "اجنبیوں کے سامنے شرماتا، چمٹتا یا ڈرتا ہے", "Ajnabiyon ke saamne sharmata, chimat-ta ya darta hai")),
        m("9m-faces", "social", T("Shows several facial expressions (happy, sad, angry, surprised)", "چہرے سے کئی جذبات دکھاتا ہے (خوشی، اداسی، غصہ، حیرت)", "Chehre se kai jazbaat dikhata hai (khushi, udaasi, ghussa, hairat)")),
        m("9m-name", "social", T("Looks when you call their name", "نام پکارنے پر دیکھتا ہے", "Naam pukarne par dekhta hai")),
        m("9m-leave", "social", T("Reacts when you leave (looks, reaches for you or cries)", "آپ کے جانے پر ردِعمل دیتا ہے (دیکھتا، ہاتھ بڑھاتا یا روتا ہے)", "Aap ke jaane par rad-e-amal deta hai (dekhta, haath barhata ya rota hai)")),
        m("9m-peekaboo", "social", T("Smiles or laughs at peek-a-boo", "چھپن چھپائی (پیک-اے-بو) پر مسکراتا یا ہنستا ہے", "Chhupan chhupai (peek-a-boo) par muskurata ya hansta hai")),
        m("9m-babbles", "language", T("Makes lots of different sounds like \"mamamama\" and \"babababa\"", "\"ماماما\" اور \"بابابا\" جیسی مختلف آوازیں نکالتا ہے", "\"mamama\" aur \"bababa\" jaisi mukhtalif awazein nikalta hai")),
        m("9m-arms", "language", T("Lifts arms up to be picked up", "اٹھانے کے لیے بازو اوپر کرتا ہے", "Uthane ke liye baazu upar karta hai")),
        m("9m-looks", "cognitive", T("Looks for things dropped out of sight", "نظر سے گری ہوئی چیز کو ڈھونڈتا ہے", "Nazar se giri hui cheez ko dhoondta hai")),
        m("9m-bangs", "cognitive", T("Bangs two things together", "دو چیزیں آپس میں ٹکراتا ہے", "Do cheezein aapas mein takrata hai")),
        m("9m-sits-up", "movement", T("Gets to a sitting position by themselves", "خود بخود بیٹھ جاتا ہے", "Khud ba khud baith jata hai")),
        m("9m-hands", "movement", T("Moves things from one hand to the other", "چیز ایک ہاتھ سے دوسرے ہاتھ میں لیتا ہے", "Cheez ek haath se doosre haath mein leta hai")),
        m("9m-rakes", "movement", T("Uses fingers to \"rake\" food towards themselves", "انگلیوں سے کھانا اپنی طرف کھینچتا ہے", "Ungliyon se khana apni taraf kheenchta hai")),
        m("9m-sits", "movement", T("Sits without support", "بغیر سہارے بیٹھتا ہے", "Baghair sahare baithta hai")),
    ], "tips": [
        T("Play peek-a-boo and hiding games with a cloth.", "کپڑے سے چھپن چھپائی کے کھیل کھیلیں۔", "Kapre se chhupan chhupai ke khel khelein."),
        T("Repeat your baby's sounds and turn them into simple words.", "بچے کی آوازیں دہرائیں اور انہیں آسان الفاظ بنائیں۔", "Bache ki awazein dohrayein aur unhein aasaan alfaaz banayein."),
        T("Offer different food textures and let them try feeding themselves.", "مختلف ساخت کے کھانے دیں اور خود کھانے کی کوشش کرنے دیں۔", "Mukhtalif saakht ke khane dein aur khud khane ki koshish karne dein."),
        T("Baby-proof the home: medicines, cleaning products and small objects out of reach.", "گھر محفوظ بنائیں: دوائیں، صفائی کی چیزیں اور چھوٹی اشیاء پہنچ سے دور رکھیں۔", "Ghar mehfooz banayein: dawaiyan, safai ki cheezein aur chhoti ashya pahunch se door rakhein."),
    ]},
    {"months": 12, "milestones": [
        m("12m-games", "social", T("Plays games with you, like pat-a-cake", "آپ کے ساتھ کھیل کھیلتا ہے، جیسے تالیاں بجانا", "Aap ke saath khel khelta hai, jaise taaliyan bajana")),
        m("12m-bye", "language", T("Waves \"bye-bye\"", "ہاتھ ہلا کر \"بائے بائے\" کرتا ہے", "Haath hila kar \"bye bye\" karta hai")),
        m("12m-mama", "language", T("Calls a parent \"mama\", \"dada\" or another special name", "ماں باپ کو \"ماما\"، \"بابا\" یا کسی خاص نام سے پکارتا ہے", "Maa baap ko \"mama\", \"baba\" ya kisi khaas naam se pukarta hai")),
        m("12m-no", "language", T("Understands \"no\" (pauses or stops)", "\"نہیں\" سمجھتا ہے (رک جاتا ہے)", "\"Nahi\" samajhta hai (ruk jata hai)")),
        m("12m-container", "cognitive", T("Puts something in a container, like a block in a cup", "چیز برتن میں ڈالتا ہے، جیسے بلاک کپ میں", "Cheez bartan mein daalta hai, jaise block cup mein")),
        m("12m-hidden", "cognitive", T("Looks for things they see you hide", "جو چیز آپ چھپائیں اسے ڈھونڈتا ہے", "Jo cheez aap chhupayein usay dhoondta hai")),
        m("12m-pulls", "movement", T("Pulls up to stand", "سہارا لے کر کھڑا ہوتا ہے", "Sahara le kar khara hota hai")),
        m("12m-cruises", "movement", T("Walks holding on to furniture", "فرنیچر پکڑ کر چلتا ہے", "Furniture pakar kar chalta hai")),
        m("12m-cup", "movement", T("Drinks from an open cup as you hold it", "آپ کے پکڑے ہوئے کھلے کپ سے پیتا ہے", "Aap ke pakre hue khule cup se peeta hai")),
        m("12m-pincer", "movement", T("Picks things up between thumb and pointer finger", "انگوٹھے اور شہادت کی انگلی سے چیزیں اٹھاتا ہے", "Angoothe aur shahadat ki ungli se cheezein uthata hai")),
    ], "tips": [
        T("Describe what you're doing during the day, and answer when your baby points.", "دن بھر جو کر رہے ہیں بتائیں، اور بچہ اشارہ کرے تو جواب دیں۔", "Din bhar jo kar rahe hain batayein, aur bacha ishara kare to jawab dein."),
        T("Save \"no\" for danger; otherwise redirect to something else.", "\"نہیں\" صرف خطرے کے لیے رکھیں؛ ورنہ توجہ کسی اور چیز کی طرف موڑیں۔", "\"Nahi\" sirf khatre ke liye rakhein; warna tawajjo kisi aur cheez ki taraf morein."),
        T("Offer water or milk in an open cup; avoid juice and sweet drinks.", "کھلے کپ میں پانی یا دودھ دیں؛ جوس اور میٹھے مشروبات سے پرہیز کریں۔", "Khule cup mein paani ya doodh dein; juice aur meethe mashroobat se parhez karein."),
        T("Let your baby practise walking holding your hands or furniture.", "بچے کو آپ کے ہاتھ یا فرنیچر پکڑ کر چلنے کی مشق کرنے دیں۔", "Bache ko aap ke haath ya furniture pakar kar chalne ki mashq karne dein."),
    ]},
    {"months": 15, "milestones": [
        m("15m-copies", "social", T("Copies other children while playing", "کھیلتے ہوئے دوسرے بچوں کی نقل کرتا ہے", "Khelte hue doosre bachon ki naqal karta hai")),
        m("15m-shows", "social", T("Shows you an object they like", "پسند کی چیز آپ کو دکھاتا ہے", "Pasand ki cheez aap ko dikhata hai")),
        m("15m-claps", "social", T("Claps when excited", "خوش ہو کر تالیاں بجاتا ہے", "Khush ho kar taaliyan bajata hai")),
        m("15m-hugs", "social", T("Shows you affection (hugs, cuddles or kisses)", "پیار دکھاتا ہے (گلے لگانا، چپکنا یا چومنا)", "Pyaar dikhata hai (gale lagana, chipakna ya choomna)")),
        m("15m-words", "language", T("Tries to say one or two words besides \"mama\" or \"dada\"", "\"ماما\" یا \"بابا\" کے علاوہ ایک دو لفظ بولنے کی کوشش کرتا ہے", "\"Mama\" ya \"baba\" ke ilawa ek do lafz bolne ki koshish karta hai")),
        m("15m-named", "language", T("Looks at a familiar object when you name it", "جانی پہچانی چیز کا نام لیں تو اسے دیکھتا ہے", "Jaani pehchani cheez ka naam lein to usay dekhta hai")),
        m("15m-directions", "language", T("Follows directions given with a gesture and words", "اشارے اور الفاظ کے ساتھ دی گئی ہدایت مانتا ہے", "Isharay aur alfaaz ke saath di gayi hidayat maanta hai")),
        m("15m-points", "language", T("Points to ask for something or to get help", "کچھ مانگنے یا مدد کے لیے اشارہ کرتا ہے", "Kuch maangne ya madad ke liye ishara karta hai")),
        m("15m-uses", "cognitive", T("Tries to use things the right way, like a phone, cup or book", "چیزوں کو صحیح طریقے سے استعمال کرنے کی کوشش کرتا ہے، جیسے فون، کپ یا کتاب", "Cheezon ko sahih tareeqe se istemal karne ki koshish karta hai, jaise phone, cup ya kitab")),
        m("15m-stacks", "cognitive", T("Stacks at least two small objects", "کم از کم دو چھوٹی چیزیں اوپر تلے رکھتا ہے", "Kam az kam do chhoti cheezein upar tale rakhta hai")),
        m("15m-steps", "movement", T("Takes a few steps on their own", "خود چند قدم چلتا ہے", "Khud chand qadam chalta hai")),
        m("15m-feeds", "movement", T("Uses fingers to feed themselves some food", "انگلیوں سے خود کچھ کھانا کھاتا ہے", "Ungliyon se khud kuch khana khata hai")),
    ], "tips": [
        T("Repeat and expand your child's words: \"ba\" becomes \"Yes, a big ball!\".", "بچے کے الفاظ دہرائیں اور بڑھائیں: \"با\" کو \"ہاں، بڑی گیند!\" بنائیں۔", "Bache ke alfaaz dohrayein aur barhayein: \"ba\" ko \"Haan, bari gaind!\" banayein."),
        T("Sing songs with actions and name feelings (\"you're sad\").", "حرکات والے گیت گائیں اور جذبات کے نام بتائیں (\"تم اداس ہو\")۔", "Harkaat wale geet gaayein aur jazbaat ke naam batayein (\"tum udaas ho\")."),
        T("Expect tantrums: they're a normal part of this age.", "ضد اور غصے کی توقع رکھیں: یہ اس عمر میں عام ہیں۔", "Zid aur ghusse ki tawaqqo rakhein: yeh is umar mein aam hain."),
        T("Practise drinking from an open cup and using a spoon.", "کھلے کپ سے پینے اور چمچ استعمال کرنے کی مشق کروائیں۔", "Khule cup se peene aur chamach istemal karne ki mashq karwayein."),
    ]},
    {"months": 18, "milestones": [
        m("18m-explores", "social", T("Moves away from you but looks to make sure you're close by", "آپ سے دور جاتا ہے لیکن دیکھتا رہتا ہے کہ آپ پاس ہیں", "Aap se door jata hai lekin dekhta rehta hai ke aap paas hain")),
        m("18m-points", "social", T("Points to show you something interesting", "دلچسپ چیز دکھانے کے لیے اشارہ کرتا ہے", "Dilchasp cheez dikhane ke liye ishara karta hai")),
        m("18m-wash", "social", T("Puts hands out for you to wash them", "ہاتھ دھلوانے کے لیے آگے کرتا ہے", "Haath dhulwane ke liye aage karta hai")),
        m("18m-book", "social", T("Looks at a few pages in a book with you", "آپ کے ساتھ کتاب کے چند صفحے دیکھتا ہے", "Aap ke saath kitab ke chand safhe dekhta hai")),
        m("18m-dress", "social", T("Helps you dress them (pushes arm through sleeve, lifts foot)", "کپڑے پہنانے میں مدد کرتا ہے (آستین میں بازو ڈالتا، پاؤں اٹھاتا ہے)", "Kapre pehnane mein madad karta hai (aasteen mein baazu daalta, paaon uthata hai)")),
        m("18m-words", "language", T("Tries to say three or more words besides \"mama\" or \"dada\"", "\"ماما\" یا \"بابا\" کے علاوہ تین یا زیادہ لفظ بولنے کی کوشش کرتا ہے", "\"Mama\" ya \"baba\" ke ilawa teen ya zyada lafz bolne ki koshish karta hai")),
        m("18m-directions", "language", T("Follows one-step directions without gestures", "بغیر اشارے کے ایک قدم کی ہدایت مانتا ہے", "Baghair isharay ke ek qadam ki hidayat maanta hai")),
        m("18m-chores", "cognitive", T("Copies you doing chores, like sweeping", "گھر کے کام میں آپ کی نقل کرتا ہے، جیسے جھاڑو دینا", "Ghar ke kaam mein aap ki naqal karta hai, jaise jharoo dena")),
        m("18m-plays", "cognitive", T("Plays with toys in a simple way, like pushing a toy car", "کھلونوں سے سادہ انداز میں کھیلتا ہے، جیسے گاڑی دھکیلنا", "Khilonon se saada andaaz mein khelta hai, jaise gaari dhakelna")),
        m("18m-walks", "movement", T("Walks without holding on to anyone or anything", "بغیر کسی سہارے کے چلتا ہے", "Baghair kisi sahare ke chalta hai")),
        m("18m-scribbles", "movement", T("Scribbles", "لکیریں کھینچتا ہے", "Lakeerein kheenchta hai")),
        m("18m-cup", "movement", T("Drinks from an open cup, maybe spilling sometimes", "کھلے کپ سے پیتا ہے، کبھی کبھار گرا دیتا ہے", "Khule cup se peeta hai, kabhi kabhar gira deta hai")),
        m("18m-feeds", "movement", T("Feeds themselves with fingers", "انگلیوں سے خود کھاتا ہے", "Ungliyon se khud khata hai")),
        m("18m-spoon", "movement", T("Tries to use a spoon", "چمچ استعمال کرنے کی کوشش کرتا ہے", "Chamach istemal karne ki koshish karta hai")),
        m("18m-climbs", "movement", T("Climbs on and off a couch or chair without help", "بغیر مدد صوفے یا کرسی پر چڑھتا اترتا ہے", "Baghair madad sofe ya kursi par charhta utarta hai")),
    ], "tips": [
        T("Offer simple choices between two things (\"banana or apple?\").", "دو چیزوں میں سے سادہ انتخاب دیں (\"کیلا یا سیب؟\")۔", "Do cheezon mein se saada intikhab dein (\"kela ya saib?\")."),
        T("Name body parts and everyday things; ask simple questions.", "جسم کے حصوں اور روزمرہ چیزوں کے نام بتائیں؛ سادہ سوال پوچھیں۔", "Jism ke hisson aur rozmarra cheezon ke naam batayein; saada sawal poochein."),
        T("Stay calm during tantrums; give a safe, quiet place to calm down.", "ضد کے وقت پرسکون رہیں؛ پرسکون ہونے کے لیے محفوظ خاموش جگہ دیں۔", "Zid ke waqt pursukoon rahein; pursukoon hone ke liye mehfooz khamosh jagah dein."),
        T("Play with push toys, balls and simple pretend play (dolls, pots).", "دھکیلنے والے کھلونوں، گیند اور سادہ فرضی کھیل (گڑیا، برتن) سے کھیلیں۔", "Dhakelne wale khilonon, gaind aur saada farzi khel (gurya, bartan) se khelein."),
    ]},
]

guide = {
    "intro": T(
        "These checklists (CDC, 2022) show what most babies, 75% or more, can do by each age. Every baby develops at their own pace, and missing one item doesn't by itself mean something is wrong.",
        "یہ فہرستیں (CDC، 2022) بتاتی ہیں کہ زیادہ تر بچے، 75% یا اس سے زیادہ، ہر عمر تک کیا کر سکتے ہیں۔ ہر بچہ اپنی رفتار سے بڑھتا ہے، اور کسی ایک چیز کا نہ ہونا بذاتِ خود کسی مسئلے کی علامت نہیں۔",
        "Yeh fehristein (CDC, 2022) batati hain ke zyada tar bachay, 75% ya is se zyada, har umar tak kya kar sakte hain. Har bacha apni raftaar se barhta hai, aur kisi ek cheez ka na hona bazat-e-khud kisi masle ki alamat nahi."),
    "actEarly": T(
        "Talk to your doctor if your baby isn't doing several things on the list for their age, has lost skills they used to have, or if you're worried for any reason. You know your baby best, and acting early helps.",
        "اگر آپ کا بچہ اپنی عمر کی فہرست کی کئی چیزیں نہیں کر رہا، پہلے سیکھی ہوئی مہارتیں کھو دے، یا آپ کو کسی بھی وجہ سے فکر ہو تو ڈاکٹر سے بات کریں۔ آپ اپنے بچے کو سب سے بہتر جانتے ہیں، اور جلدی قدم اٹھانا مددگار ہوتا ہے۔",
        "Agar aap ka bacha apni umar ki fehrist ki kai cheezein nahi kar raha, pehle seekhi hui maharatein kho de, ya aap ko kisi bhi wajah se fikr ho to doctor se baat karein. Aap apne bache ko sab se behtar jaante hain, aur jaldi qadam uthana madadgaar hota hai."),
    "source": "CDC Learn the Signs. Act Early. milestone checklists (2022).",
}

with open(OUT, "w", encoding="utf-8") as f:
    json.dump({"ages": ages, "guide": guide}, f, ensure_ascii=False, indent=1)
print(sum(len(a["milestones"]) for a in ages), "milestones written to", OUT)
