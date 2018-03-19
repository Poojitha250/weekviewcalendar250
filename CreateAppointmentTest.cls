@isTest
public class CreateAppointmentTest {
	@isTest
    static void test1(){
        Lead le=new Lead();
        le.FirstName='test';
        le.lastname='abc';
        le.Phone='8475894444';
        le.Company='abc';
        insert le;
        Event ev=new Event();
        ev.subject='test sub';
        ev.location='test loc';
        ev.StartDateTime=DateTime.now();
        ev.EndDateTime=DateTime.now()+1;
        ev.whoId=le.Id;
        insert ev;
        ApexPages.StandardController stdctrl=new ApexPages.StandardController(le); 
        CreateAppointmentController ctrl=new CreateAppointmentController(stdctrl);
        CreateAppointmentController.EventWrapper ewp=new CreateAppointmentController.EventWrapper(1,'2015-12-01T12:44:00.000+0000','2015-12-01T12:44:00.000+0000','test','test2');
        String ewstr=JSON.serialize(ewp);
           
        ctrl.newEventData=JSON.serialize(ewp);
        ctrl.createNewAppointment();
        ctrl.saveAppointment();
        System.assertEquals(true,[SELECT isconverted FROM Lead where id=:le.id].isconverted);
    }
}