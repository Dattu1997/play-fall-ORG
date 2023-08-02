public class NewCaseListController {
    public List<Case> getNewCases(){
        List<Case> caseList = [select Id, CaseNumber, status from case where status ='New'];
        return caseList;
    }

}