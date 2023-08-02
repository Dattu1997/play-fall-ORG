public class WrapperForAccount{
	public cls_records[] records;
	class cls_records {
		public cls_attributes attributes;
		public String name;	//SampleAccount1
		public String phone;	//1111111111
		public String website;	//www.salesforce1.com
		public String numberOfEmployees;	//100
		public String industry;	//Banking
	}
    public class cls_attributes {
		public String type;	//Account
		public String referenceId;	//ref1
	}
}