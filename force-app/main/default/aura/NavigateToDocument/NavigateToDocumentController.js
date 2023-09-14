({
    init: function (cmp, evt, helper) {
        
        cmp.set('v.quoteId', '');
        cmp.set('v.objectDetails',null);
        
        var myPageRef = cmp.get('v.pageReference');
        var recordId = myPageRef.state.c__recordId;

        var action = cmp.get('c.getObjectDetails');
        action.setParams({
            recordId: recordId          
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.objectDetails', response.getReturnValue());
                cmp.set('v.quoteId', recordId);
               
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        });

        $A.enqueueAction(action);
    },
});