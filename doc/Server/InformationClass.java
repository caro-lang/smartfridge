package service.database.classes;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import statistics.classes.ContentStat;
import statistics.classes.Count_Name_Class;

public class InformationClass {

	public String info;
	public Boolean cmd_Performed;
	public String token;
	public String error;
	public String userQuestion;
	public Integer remainingTrys;
	public Integer createtID;
	public ArrayList<Fridge> fridgeList;
	public ArrayList<SimpleElement> elementList;
	public User user;
	public Product product;
	public ArrayList<Product> productList;
	public ArrayList<Content> contentList;
	public ArrayList<BuyListContent> buyListContent;
	
	/*Statistics*/
	public ArrayList<Count_Name_Class> statistics_Count;
	public Double average;
	public ArrayList<ContentStat> contentstats;

}
