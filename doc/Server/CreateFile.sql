/*Drop database if exists smartfridge;*/

CREATE DATABASE smartfridge;


CREATE TABLE smartfridge.querys (
	QueryContent varchar(3000) NOT NULL,
    JSONAnswer varchar(3000) NOT NULL,
    Time_Of Datetime
);

delimiter $
CREATE TRIGGER smartfridge.queryTime BEFORE INSERT ON smartfridge.querys
FOR EACH ROW
BEGIN
	IF NEW.Time_Of IS NULL THEN
       SET NEW.Time_Of = NOW();
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.question (
QuestionID int NOT NULL auto_increment,
Question varchar(500) NOT NULL,
primary key(QuestionID)
);

CREATE TABLE smartfridge.user (
UserID int NOT NULL auto_increment ,
UserName varchar(255) NOT NULL,
Male Bit NOT NULL,
Birthday date NOT NULL,
Prename varchar(255) NOT NULL,
Surname varchar(255) NOT NULL,
PwdHash varchar(255) NOT NULL,
QuestionAnswerHash varchar(255) NOT NULL,
QuestionID int NOT NULL,
Salt varchar(255) NOT NULL,
CreateTime Datetime,
DeleteTime Datetime,
foreign key(QuestionID) references smartfridge.question(QuestionID),
PRIMARY KEY (UserID)/*,
CONSTRAINT OneActiveUsername CHECK (smartfridge.fn_Check_Username(UserName)=1)*/
);

delimiter $
CREATE TRIGGER smartfridge.oneActiveUsername BEFORE INSERT ON smartfridge.user
FOR EACH ROW
BEGIN
	IF NEW.CreateTime IS NULL THEN
       SET NEW.CreateTime = NOW();
    END IF;
    IF (SELECT count(UserID) FROM smartfridge.user U where U.DeleteTime is Null AND U.UserName = New.username) > 0 THEN
        SIGNAL SQLSTATE '12345'
        SET MESSAGE_TEXT = 'Username excists';
        
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.passwordReset(
ResetID int NOT NULL auto_increment,
UserID int not null,
TryTime datetime,
Successful Bit default false,
foreign key(UserID) references smartfridge.user(UserID),
primary key(ResetID)
);

delimiter $
CREATE TRIGGER smartfridge.resetTime BEFORE INSERT ON smartfridge.passwordReset
FOR EACH ROW
BEGIN
	IF NEW.TryTime IS NULL THEN
       SET NEW.TryTime = NOW();
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.token (
TokenID int NOT NULL auto_increment ,
UserID int NOT NULL,
Token varchar(255) NOT NULL Unique,
UserClient varchar(255) NOT NULL,
CreateTime Datetime,
Stay_Logged_In bit DEFAULT false,
Log_Out_Time Datetime,
foreign key(UserID) references smartfridge.user(UserID),
primary key(TokenID)
);

delimiter $
CREATE TRIGGER smartfridge.tokenTime BEFORE INSERT ON smartfridge.token
FOR EACH ROW
BEGIN
	IF NEW.CreateTime IS NULL THEN
       SET NEW.CreateTime = NOW();
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.tokenUsed (
TokenUsedID int NOT NULL auto_increment ,
TokenID int NOT NULL,
IP_Address varchar(255),
UsedTime Datetime,
primary key(TokenUsedID),
foreign key(TokenID) references smartfridge.token(TokenID)
);

delimiter $
CREATE TRIGGER smartfridge.usedTime BEFORE INSERT ON smartfridge.tokenUsed
FOR EACH ROW
BEGIN
	IF NEW.UsedTime IS NULL THEN
       SET NEW.UsedTime = NOW();
    END IF;
END$  
DELIMITER ;



CREATE TABLE smartfridge.fridge(
FridgeID int NOT NULL auto_increment,
FridgeName varchar(255) NOT NULL,
UserID int NOT NULL,
Temperature real,
DeleteTime Datetime,
foreign key(UserID) references smartfridge.user(UserID),
primary key(FridgeID)
);

delimiter $
CREATE TRIGGER smartfridge.NoSameFridgeName BEFORE INSERT ON smartfridge.fridge
FOR EACH ROW
BEGIN
    IF (SELECT count(FridgeName) FROM smartfridge.fridge F where DeleteTime is NUll AND F.FridgeName = New.FridgeName AND F.UserID = New.UserID) > 0 THEN
        SIGNAL SQLSTATE '12345'
        SET MESSAGE_TEXT = 'Fridgename excists';
        
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.maincategory(
MaincategoryID int NOT NULL auto_increment,
CategoryName varchar(255) NOT NULL Unique,
primary key(MaincategoryID)
);

CREATE TABLE smartfridge.subcategory(
SubcategoryID int NOT NULL auto_increment,
MaincategoryID int NOT NULL,
CategoryName varchar(255) NOT NULL Unique,
primary key(SubcategoryID),
foreign key(MaincategoryID) references smartfridge.maincategory(MaincategoryID)
);

CREATE TABLE smartfridge.Country_Of_Manufacture(
Country_Of_ManufactureID int NOT NULL auto_increment,
Country_Name varchar(255) NOT NULL Unique,
primary key(Country_Of_ManufactureID)
);

CREATE TABLE smartfridge.manufacture(
ManufactureID int NOT NULL auto_increment,
ManufactureName varchar(255) NOT NULL Unique,
primary key(ManufactureID)
);

CREATE TABLE smartfridge.product(
ProductID int NOT NULL auto_increment,
Barcode varchar(128) unique,
ProductName varchar(255) NOT NULL,
DetailName varchar(512),
Description varchar(8000),
ManufactureID int,
SubcategoryID int NOT NULL,
Country_Of_ManufactureID int,
Created_By int NOT NULL,
AmazonURL varchar(1000),
primary key(ProductID),
foreign key(ManufactureID) references smartfridge.manufacture(ManufactureID),
foreign key(Created_By) references smartfridge.user(UserID),
foreign key (Country_Of_ManufactureID) references smartfridge.Country_Of_Manufacture(Country_Of_ManufactureID),
foreign key(SubcategoryID) references smartfridge.subcategory(SubcategoryID)
);

CREATE TABLE smartfridge.productChanges(
ProductChangesID int NOT NULL auto_increment,
ProductID int NOT NULL,
Changed_By int NOT NULL,
Changed_Content varchar(2000),
CreateTime Datetime,
primary key(ProductChangesID),
foreign key(Changed_By) references smartfridge.user(UserID),
foreign key(ProductID) references smartfridge.product(ProductID)
);

delimiter $
CREATE TRIGGER smartfridge.changeTime BEFORE INSERT ON smartfridge.productChanges
FOR EACH ROW
BEGIN
	IF NEW.CreateTime IS NULL THEN
       SET NEW.CreateTime = NOW();
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.ingredients(
IngredientsID int NOT NULL auto_increment,
IngredientsName varchar (255) NOT NULL Unique,
primary key(IngredientsID)
);

CREATE TABLE smartfridge.Productingredients(
IngredientsID int NOT NULL,
ProductID int NOT NULL,
Constraint keypair primary key (IngredientsID, ProductID),
foreign key (IngredientsID) references smartfridge.ingredients(IngredientsID),
foreign key (ProductID) references smartfridge.product(ProductID)
);

CREATE TABLE smartfridge.productpicture(
ProductPictureID int NOT NULL auto_increment,
ProductID int NOT NULL,
PictureURL varchar(750) NOT NULL,
primary key(ProductPictureID),
foreign key(ProductID) references smartfridge.product(ProductID)
);

CREATE TABLE smartfridge.PackingMaterial(
PackingMaterialID int NOT NULL auto_increment,
PackingName varchar(255) NOT NULL Unique,
primary key(PackingMaterialID)
);

CREATE TABLE smartfridge.ProductPackingmaterials(
PackingMaterialID int NOT NULL,
ProductID int NOT NULL,
Constraint keypair primary key (PackingMaterialID, ProductID),
foreign key (PackingMaterialID) references smartfridge.PackingMaterial(PackingMaterialID),
foreign key (ProductID) references smartfridge.product(ProductID)
);


CREATE TABLE smartfridge.content(
ContentID int NOT NULL auto_increment,
FridgeID int NOT NULL,
ProductID int NOT NULL,
Date_of_purchase date,
Bought_at varchar(255),
Durability date NOT NULL,
Price real, 
valuation real CHECK (valuation>=0 AND valuation <=5),
Rotten_Date date,
primary key(ContentID),
foreign key(ProductID) references smartfridge.product(ProductID),
foreign key(FridgeID) references smartfridge.fridge(FridgeID),
CONSTRAINT Pos_Price CHECK (Price>0)
);

delimiter $
CREATE TRIGGER smartfridge.autoPurchase BEFORE INSERT ON smartfridge.content
FOR EACH ROW
BEGIN
	IF NEW.Date_of_purchase IS NULL THEN
       SET NEW.Date_of_purchase = NOW();
    END IF;
END$  
DELIMITER ;

CREATE TABLE smartfridge.consumption(
ConsumptionID int NOT NULL auto_increment,
ContentID int NOT NULL,
ConsumDate Datetime,
Percentage_Consumption int NOT NULL default 100,
/*CONSTRAINT Pos_Consum CHECK (Percentage_Consumption>0),*/
primary key(ConsumptionID),
foreign key(ContentID) references smartfridge.content(ContentID)
);

delimiter $
CREATE TRIGGER smartfridge.Check_Percent BEFORE INSERT ON smartfridge.consumption
FOR EACH ROW
BEGIN
	IF NEW.ConsumDate IS NULL THEN
       SET NEW.ConsumDate = NOW();
    END IF;
    IF NEW.Percentage_Consumption<=0 THEN
		SIGNAL SQLSTATE '12345'
        SET MESSAGE_TEXT = 'Negative Consum';
    END IF;
    IF (((Select SUM(Percentage_Consumption) FROM smartfridge.consumption C where C.contentID = New.contentID)+New.Percentage_Consumption)>100) THEN
        SIGNAL SQLSTATE '12345'
        SET MESSAGE_TEXT = 'Over 100 Percent used';        
    END IF;
END$ 
DELIMITER ;

INSERT INTO smartfridge.question (QuestionID, Question) VALUES ('1','Was ist Ihr Lieblingsfilm?'),('2','In welcher Straße sind Sie aufgewachsen?');

/*Kategorien anlegen*/
INSERT INTO smartfridge.maincategory (MaincategoryID, CategoryName) VALUES ('1', 'Baby, Kind'), ('2', 'Backwaren'), ('3', 'Brotaufstriche'), ('4', 'Dessert, Nachtisch'), ('5', 'Eier'), ('6', 'Fertiggerichte'), ('7', 'Fleisch, Fisch'), ('8', 'Früchte, Obst'), ('9', 'Gemüse'), ('10', 'Getränke, Alkohol'), ('11', 'Kochzutaten'), ('12', 'Konditorei, Zuckerwaren'), ('13', 'Milchprodukte'), ('14', 'Sojaprodukte'), ('15', 'Süsswaren, Snacks'), ('16', 'Anderes');
INSERT INTO smartfridge.subcategory (MaincategoryID, CategoryName) VALUES ('1', 'Babygetränke'), ('1', 'Babynahrung'), ('1', 'Gesundheit, Pflege'), ('2', 'Backmischungen'), ('2', 'Backzutaten'), ('2', 'Brotarten'), ('2', 'Dauerbackwaren, Zwieback'), ('2', 'Frischbackwaren'), ('2', 'Gebäck, Panettone'), ('2', 'Hefe'), ('2', 'Kuchen, Cakes'), ('2', 'Teig'), ('3', 'Honig'), ('3', 'Konfitüren, Marmeladen'), ('3', 'verschiedene'), ('4', 'Creme'), ('4', 'Pudding'), ('4', 'Speiseeis'), ('5', 'Eier'), ('6', 'Andere'), ('6', 'Asia Gerichte'), ('6', 'Bouillon, Brühe'), ('6', 'Fleischerzeugnisse'), ('6', 'Gericht, Menü;'), ('6', 'Kartoffelprodukte'), ('6', 'Pasta'), ('6', 'Pizza'), ('6', 'Sandwich'), ('6', 'Saucen'), ('6', 'Suppen'), ('6', 'Tiefgekühltes, Tiefkühlkost'), ('7', 'Fisch'), ('7', 'Fischkonserven'), ('7', 'Fleischkonserven'), ('7', 'Frischfleisch'), ('7', 'Geflügel'), ('7', 'Meeresfrüchte'), ('7', 'Trockenfleisch, Salami'), ('7', 'Wurstwaren'), ('8', 'Exotische Früchte'), ('8', 'Früchte, Obst'), ('8', 'Nüsse'), ('8', 'Obstkonserven'), ('8', 'Trockenfrüchte'), ('8', 'kandierte Früchte'), ('9', 'Antipasti'), ('9', 'Essigkonserven'), ('9', 'Gemüse'), ('9', 'Gemüsekonserven'), ('9', 'Salat'), ('9', 'Trockengemüse'), ('10', 'Alcopops'), ('10', 'Bier'), ('10', 'Energy Drinks'), ('10', 'Frucht-und Gemüsesäfte'), ('10', 'Instantgetränke'), ('10', 'Kaffee'), ('10', 'Kakao,Schokoladen'), ('10', 'Limonaden'), ('10', 'Wasser'), ('10', 'Sirup'), ('10', 'Spirituosen'), ('10', 'Tee'), ('10', 'Wein/Sekt/Champagner'), ('11', 'Backpulver'), ('11', 'Essig'), ('11', 'Frische Gewürze'), ('11', 'Gelatine'), ('11', 'Gewürze'), ('11', 'Mehl'), ('11', 'Öl, Fette'), ('11', 'Salz'), ('11', 'Senf, Mayonnaise, Püree, Cremen'), ('11', 'Stärkearten'), ('12', 'Kuchendekoration'), ('12', 'Marzipan'), ('12', 'Süßstoffe'), ('12', 'Zucker'), ('13', 'Butter, Margarine'), ('13', 'Joghurt'), ('13', 'Käse'), ('13', 'Milch'), ('13', 'Milchgetränke'), ('13', 'Quark'), ('13', 'Rahm, Rahmprodukte'), ('14', 'Sojamilch'), ('14', 'Sojasaucen'), ('14', 'Tofu'), ('14', 'sonstiges'), ('15', 'Bisquits, Kekse, Konfekt'), ('15', 'Bonbons'), ('15', 'Chips'), ('15', 'Energiespender'), ('15', 'Fruchtgummi'), ('15', 'Getreide, Schokoriegel, Waffeln'), ('15', 'Kaugummi'), ('15', 'Schokolade'), ('15', 'salzige Snacks'), ('15', 'Mais'), ('16', 'Anderes (Bitte präzise Detailbeschreibung)');

/*Inhaltsstoffe*/
INSERT INTO smartfridge.ingredients (IngredientsName) VALUES ('laktosefrei'), ('fruktosefrei'), ('koffeinfrei'), ('glutenfrei'), ('vegetarisch'), ('vegan'), ('diätetisches Lebensmittel'), ('BIO-Produkt'), ('enthält Mikroplastik'), ('enthält Mineralöl'), ('enthält Nikotin');

/*Verpackungsmaterial*/
INSERT INTO smartfridge.PackingMaterial (PackingName) VALUES ('zu stark verpackt'), ('zu wenig verpackt'), ('Pfand'), ('Papier'), ('Karton'), ('Pappe'), ('Innenbeschichtung wie Polyolefinen, Fluortelomeren oder Aluminium'), ('Metall wie Aluminium'), ('Biokunststoffe'), ('Glas'), ('PET (Polyethylenterephthalat )'), ('PE (Polyethylen)'), ('PVC (Polyvinylchlorid)'), ('PP (Polypropylen)'), ('PS (Polystyrol)'), ('P (Polyamid)'), ('PC (Polycarbonat)'), ('unverpackt');

INSERT INTO smartfridge.Country_Of_Manufacture (Country_Name) VALUES ('Afghanistan'), ('Ägypten'), ('Åland'), ('Albanien'), ('Algerien'), ('Amerikanische Jungferninseln'), ('Amerikanisch-Samoa'), ('Andorra'), ('Angola'), ('Anguilla'), ('Antarktika'), ('Antigua und Barbuda'), ('Äquatorialguinea'), ('Argentinien'), ('Armenien'), ('Aruba'), ('Aserbaidschan'), ('Äthiopien'), ('Australien'), ('Bahamas'), ('Bahrain'), ('Bangladesch'), ('Barbados'), ('Bassas da India'), ('Belarus'), ('Belgien'), ('Belize'), ('Benin'), ('Bermuda'), ('Bhutan'), ('Bolivien'), ('Bosnien und Herzegowina'), ('Botsuana'), ('Bouvetinsel'), ('Brasilien'), ('Britische Jungferninseln'), ('Britisches Territorium im Indischen Ozean'), ('Brunei Darussalam'), ('Bulgarien'), ('Burkina Faso'), ('Burundi'), ('Cabo Verde'), ('Chile'), ('China'), ('Clipperton'), ('Cookinseln'), ('Costa Rica'), ('Côte d\'Ivoire'), ('Dänemark'), ('Deutschland'), ('Dominica'), ('Dominikanische Republik'), ('Dschibuti'), ('Ecuador'), ('El Salvador'), ('Eritrea'), ('Estland'), ('Europa'), ('Falklandinseln'), ('Färöer'), ('Fidschi'), ('Finnland'), ('Frankreich'), ('Frankreich (metropolitanes)'), ('Französische Süd- und Antarktisgebiete'), ('Französisch-Guayana'), ('Französisch-Polynesien'), ('Gabun'), ('Gambia'), ('Gazastreifen'), ('Georgien'), ('Ghana'), ('Gibraltar'), ('Glorieuses'), ('Grenada'), ('Griechenland'), ('Grönland'), ('Großbritannien'), ('Guadeloupe'), ('Guam'), ('Guatemala'), ('Guernsey'), ('Guinea'), ('Guinea-Bissau'), ('Guyana'), ('Haiti'), ('Heard und McDonaldinseln'), ('Honduras'), ('Hongkong'), ('Indien'), ('Indonesien'), ('Insel Man'), ('Irak'), ('Iran'), ('Irland'), ('Island'), ('Israel'), ('Italien'), ('Jamaika'), ('Japan'), ('Jemen'), ('Jersey'), ('Jordanien'), ('Juan de Nova'), ('Kaimaninseln'), ('Kambodscha'), ('Kamerun'), ('Kanada'), ('Kasachstan'), ('Katar'), ('Kenia'), ('Kirgisistan'), ('Kiribati'), ('Kleinere Amerikanische Überseeinseln'), ('Kokosinseln (Keelinginseln)'), ('Kolumbien'), ('Komoren'), ('Kongo'), ('Kongo, Demokratische Republik'), ('Korea, Demokratische Volksrepublik'), ('Korea, Republik'), ('Kroatien'), ('Kuba'), ('Kuwait'), ('Laos'), ('Lesotho'), ('Lettland'), ('Libanon'), ('Liberia'), ('Libyen'), ('Liechtenstein'), ('Litauen'), ('Luxemburg'), ('Macau'), ('Madagaskar'), ('Malawi'), ('Malaysia'), ('Malediven'), ('Mali'), ('Malta'), ('Marokko'), ('Marshallinseln'), ('Martinique'), ('Mauretanien'), ('Mauritius'), ('Mayotte'), ('Mazedonien'), ('Mexiko'), ('Mikronesien'), ('Moldau'), ('Monaco'), ('Mongolei'), ('Montenegro'), ('Montserrat'), ('Mosambik'), ('Myanmar'), ('Namibia'), ('Nauru'), ('Nepal'), ('Neukaledonien'), ('Neuseeland'), ('Nicaragua'), ('Niederlande'), ('Niederländische Antillen'), ('Niger'), ('Nigeria'), ('Niue'), ('Nördliche Marianen'), ('Norfolkinsel'), ('Norwegen'), ('Oman'), ('Österreich'), ('Pakistan'), ('Palau'), ('Panama'), ('Papua-Neuguinea'), ('Paraguay'), ('Peru'), ('Philippinen'), ('Pitcairninseln'), ('Polen'), ('Portugal'), ('Puerto Rico'), ('Réunion'), ('Ruanda'), ('Rumänien'), ('Russische Föderation'), ('Saint-Martin'), ('Salomonen'), ('Sambia'), ('Samoa'), ('San Marino'), ('São Tomé und Príncipe'), ('Saudi-Arabien'), ('Schweden'), ('Schweiz'), ('Senegal'), ('Serbien'), ('Serbien und Montenegro'), ('Seychellen'), ('Sierra Leone'), ('Simbabwe'), ('Singapur'), ('Slowakei'), ('Slowenien'), ('Somalia'), ('Spanien'), ('Spitzbergen'), ('Sri Lanka'), ('St. Barthélemy'), ('St. Helena, Ascension und Tristan da Cunha'), ('St. Kitts und Nevis'), ('St. Lucia'), ('St. Pierre und Miquelon'), ('St. Vincent und die Grenadinen'), ('Südafrika'), ('Sudan'), ('Südgeorgien und die Südlichen Sandwichinseln'), ('Südsudan'), ('Suriname'), ('Swasiland'), ('Syrien'), ('Tadschikistan'), ('Taiwan'), ('Tansania'), ('Thailand'), ('Timor-Leste'), ('Togo'), ('Tokelau'), ('Tonga'), ('Trinidad und Tobago'), ('Tromelin'), ('Tschad'), ('Tschechische Republik'), ('Tunesien'), ('Türkei'), ('Turkmenistan'), ('Turks- und Caicosinseln'), ('Tuvalu'), ('Uganda'), ('Ukraine'), ('Ungarn'), ('Uruguay'), ('Usbekistan'), ('Vanuatu'), ('Vatikanstadt'), ('Venezuela'), ('Vereinigte Arabische Emirate'), ('Vereinigte Staaten'), ('Vietnam'), ('Wallis und Futuna'), ('Weihnachtsinsel'), ('Westjordanland'), ('Westsahara'), ('Zentralafrikanische Republik'), ('Zypern');


