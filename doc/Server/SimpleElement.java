package database.classes;

public class SimpleElement {
	
	public int id;
	public String name;
	public Integer foreign_ID;
	
	public SimpleElement(int id, String name) {
		this.id = id;
		this.name = name;
	}
	
	public SimpleElement(int id, String name, int foreign_ID) {
		this(id,name);
		this.foreign_ID = foreign_ID;
	}
	
	public int hashCode() {
		return id;
	}
	
	@Override
	public boolean equals(Object obj) {
		if(!(obj instanceof SimpleElement)) return false;
		return this.id == ((SimpleElement) obj).id;
	}

}
