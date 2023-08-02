({
    refreshHandler: function (component, event, helper) {
        console.log('inside refresh');
        if (component.get('v.recordId') != null && component.get('v.recordId') != undefined) {
            $A.get('e.force:refreshView').fire();
        }
    }
})