package service.database.classes;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Product {

	public Integer id;
	public String Barcode;
	public String Productname;
	public String Detailname;
	public String Description;
	public SimpleElement Maincategory;
	public SimpleElement Subcategory;
	public SimpleElement Manufacture;
	public SimpleElement Country;
	public boolean wasinDB=false;
	public Set<SimpleElement> ingredients = new HashSet<SimpleElement>();
	public Set<SimpleElement> packingMaterial = new HashSet<SimpleElement>();
	public Set<String> pictures = new HashSet<String>();
	public Integer amount_mul_100;
	public String unit;
	public Integer daysToRotten;
	public Double estimatedPrice;
}
