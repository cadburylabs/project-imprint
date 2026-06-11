






        
var ADD_PEOPLE_AND_RESOURCES = "Please pick at least one entry and/or resource.";
var CHOOSE_TIME_RANGE = "Please schedule a time range for this event";
var TITLE = "Title";
var LOCATION = "Location";
var TIME = "Time";
var ORGANIZER = "Organizer";


var SCHEDULE_EVENT_BUTTON_NAME = "createevent";

var T_GROUP = "group";
var T_ENTITY = "entity";
var T_RESOURCE = "resource";

var ITEM_TYPE_TRANSLATIONS = Object.freeze({
	entity: 'Entity',
	resource: 'Resource'
});

var PARAM_DATE = "date";
var PARAM_TIME = "time";
var PARAM_END_TIME = "endtime";
var PARAM_LOCATION = "location";


//state attribute indices

// these actions will rquest availability from server
var ACTION_SELECT_GROUP = 0;
var ACTION_ADD_ITEMS = 1;
var ACTION_NEW_DATE = 2;


var TEXT_SCALE = 1.0;


var TIME_INTERVAL = 30;    //30 minutes
var WORK_DAY_START = 480; //8:00am
var WORK_DAY_END = 1110;    //6:30pm

var SLOT_AVAILABLE = 'available';
var SLOT_UNAVAILABLE = "unavailable";
var SLOT_TENTATIVE = "tentative";
var SLOT_SELECTED = "selected";


String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ""); };

/**************************************************************************
 global functions
**************************************************************************/
function addItem(schedulerId, itemIdFieldId)
{

    var itemIdField = document.getElementsByName(itemIdFieldId)[0];
    if (itemIdField == null)
        return;
    if (itemIdField.value == "")
    {
        alert(ADD_PEOPLE_AND_RESOURCES);
        return;
    }

    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
       var item = {};
        if (itemIdField.value.substring(itemIdField.value.length-2)=="_r")
        {
            item.id = itemIdField.value.substring(0, itemIdField.value.length - 2);
            item.type = T_RESOURCE;
            item.label = ITEM_TYPE_TRANSLATIONS[T_RESOURCE];
        }
        else
        {
            item.id = itemIdField.value;
            item.type = T_ENTITY;
            item.label = ITEM_TYPE_TRANSLATIONS[T_ENTITY];
        }
        scheduler.getAvailability(item, null, ACTION_ADD_ITEMS);
    }
}


/**
 * add items
 * @param labels item labels
 * @param ids item ids
 * @param schedulerId the id of scheduler
 * @param the type of items
 */
function addItems(label, id, type, schedulerId)
{
    var scheduler = window['scheduler' + schedulerId];
    var items = [];
    var ids = id.split(String.fromCharCode(5));
    for (var i = 0; i < ids.length; i++)
    {
        var item = {};
        item.id = ids[i];
        item.type = type;
		item.label = ITEM_TYPE_TRANSLATIONS[type] ? ITEM_TYPE_TRANSLATIONS[type] : '';
        items[items.length] = item;
    }
    if (items.length > 0)
        scheduler.getAvailability(null, items, ACTION_ADD_ITEMS);
}

/**
 * change date by incease/decrease one day and update the availability
 * @param schedulerId the id of the scheduler object
 * @param id the id of the item
 * @bIncease increase or decrease by one day
 *
 */
function changeDate(schedulerId, fieldId, bIncrease)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
        scheduler.changeDate(fieldId, bIncrease);
    }
}

function createEvent(schedulerId)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
        return scheduler.createEvent();
    }
    return false;
}

function selectGroup(schedulerId, id)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
        scheduler.selectGroup(id);
    }
}

function selectTimeSlot(schedulerId, dayIdx, timeIdx)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
        scheduler.selectTimeSlot(dayIdx, timeIdx);
    }
}


/*
 *@parame fieldId the calendar date field id
 */
function setDate(schedulerId, fieldId)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
    {
        scheduler.setNewDate(fieldId);
    }
}

/*
 * toggle the selection of an iem
 * @param schedulerId the id of the scheduler object
 * @param id the id of the item
 */
function toggleItemSelect(schedulerId, id)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
        scheduler.toggleItemSelect(id);
}

/*
 * toggle the selection of an iem
 * @param schedulerId the id of the scheduler object
 * @param id the id of the item
 */
function toggleAllItemsSelect(schedulerId, fieldId)
{
    var scheduler = window['scheduler' + schedulerId];
    if (scheduler != null)
        scheduler.toggleAllItemsSelect();
}

/**************************************************************************
 scheduler object
**************************************************************************/
/**
 * @param id the id will be used as part of the html control ids and should be unique in a page
 */
function nlScheduler (id, workDayStart, workDayEnd, dateField, portletUrl, bMinimized)
{

    this.numDays = 1;                      //TODO change to support weekly view
    this.id = id;
    this.htmlId = 'scheduler' + id;
    this.formName = this.id + "_form";

    this.portletUrl = portletUrl;
    this.bMinimized = bMinimized;
    this.bLoadedMinimized = bMinimized;

    this.selectedDate = new Date();

    //workday start/end
    //this.workDayStart = (workDayStart == "undefined") ? WORK_DAY_START : workDayStart;
    //this.workDayEnd = (workDayEnd == "undefined") ? WORK_DAY_END: workDayEnd;
    this.startTimeInMinutes = (workDayStart == "undefined") ? WORK_DAY_START : workDayStart;
    this.endTimeInMinutes = (workDayEnd == "undefined") ? WORK_DAY_END: workDayEnd;

    this.timeInterval = TIME_INTERVAL;

    //number of time slots;
    this.numTimeSlots = Math.ceil((this.endTimeInMinutes - this.startTimeInMinutes) / this.timeInterval);

    this.renderer = new nlSchedulerRenderer(this);

    this.renderer.setControlIds(dateField);

    window[this.htmlId] = this;

    var form = document.getElementById(this.formName);
    if (form != null)
        form.onsubmit = () => createEvent(this.id);

    this.init();

    this.addEventHandlers();

    this.loadState();

    this.renderer.showDate (this.selectedDate);

    this.renderer.showBusyIndicator(false);
 }


nlScheduler.prototype.addItems = function ( response, action )
{
    var sText = response.getBody();
    var doc = nlapiStringToXML (sText);

    if (doc.getElementsByTagName('availability').length == 0)
        return;

    var dateStr = doc.getElementsByTagName('availability')[0].getAttribute('date');
    var date = Date.parse(dateStr);
    var dayIdx = this.getDateIndexInWeek(date);
    var records = doc.getElementsByTagName('record');
    for(var i=records.length-1; i>=0; i--)
    {
        var id = records[i].getAttribute('id');

        //skip groups
        if (id == this.pendingQueryGroupId)
            continue;

        var item = this.items[id];
        if (item == null)
        {
            item = new nlItem(this);
            item.id = id;
            item.name = records[i].getAttribute('name');
            item.type = records[i].getAttribute('type');
			item.label = ITEM_TYPE_TRANSLATIONS[item.type] ? ITEM_TYPE_TRANSLATIONS[item.type] : '';


            // resource is at the top of the list, followed by people
            var pos;
            if (item.type == T_RESOURCE)
            {
                pos = 0;
                this.numResources++;
                item.location = records[i].getAttribute('location') != null ? records[i].getAttribute('location') : "";
            }
            else
                pos = this.numResources;

            this.items[item.id] = item;
            this.orderedItems.splice(pos, 0, item);

            if (action == ACTION_SELECT_GROUP || action == ACTION_ADD_ITEMS)
                this.addSelectedItem(id);
        }
        item.clearAvailability();
        var events = records[i].getElementsByTagName('event');

        for (var j=0; j<events.length; j++)
            this.setItemAvailability(item, dayIdx, events[j]);

        this.updateCommonAvailability(item, true /*add*/);
    }

    this.updateSelectedTimeSlots();

    if (this.getSizeOfItems() >0 && this.getSizeOfSelectedItems() == this.getSizeOfItems())
        this.bAllItemsSelected = true;

    if (this.bMinimized)
        return;

    this.renderer.showItems(true);
    this.renderer.showCommonAvailability();

    if (this.selectedStartTime != null && this.selectedEndTime != null)
    {
        var selected = this.getSelectedTimeSlots();
        this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, true /*hightlight*/);
    }

    if (this.getSizeOfItems() >0 && this.getSizeOfSelectedItems() == this.getSizeOfItems())
        this.renderer.updateSelectAllCheckBox(true);

    this.renderer.updateScheduleEventButton();

    this.pendingQueryGroupId = "";
    this.renderer.showBusyIndicator(false);
};

/**
 * change date by incease/decrease one day and update the availability
 * @param id the id of the item
 * @bIncease increase or decrease by one day
 *
 */
nlScheduler.prototype.changeDate = function(fieldId, bIncrease)
{
    var newDate = adddays(this.selectedDate, bIncrease?1:-1);

    this.renderer.showDate (newDate);

    this.setNewDate(fieldId);
};


nlScheduler.prototype.selectGroup = function (id)
{
    if (typeof id == "undefined")
        id = "";

    this.init();
    this.groupId = id;

    if (id == "")
        return;

    var item = {};
    item.type = T_GROUP;
    item.id = id;
    this.getAvailability(item, null, ACTION_SELECT_GROUP);
};

nlScheduler.prototype.createEvent = function ()
{
    var msg = "";
    if (this.selectedStartTime == null)
        msg = CHOOSE_TIME_RANGE + "\n";
    if (this.getSizeOfSelectedItems() == 0)
        msg +=  ADD_PEOPLE_AND_RESOURCES;

    if (msg != "")
    {
        alert(msg);
        return false;
    }

    var form = document.getElementById(this.formName);
    if (form == null)
        return false;

    var entityIdx = 0;
    var resourceIdx = 0;

    // add items fields (entity or resource);
    for (var key in this.selectedItems)
    {
        var item = this.getSelectedItem(key);
        if (item != null)
        {
            var field = document.createElement("INPUT");
            field.type="hidden";
            if (item.type == T_ENTITY)
                field.name = T_ENTITY + entityIdx++;
            else
                field.name = T_RESOURCE + resourceIdx++;
            field.value = item.id;
            form.appendChild(field);
        }
    }
    // add date and time fields;
    var field = document.createElement("INPUT");
    field.type="hidden";
    field.name = PARAM_DATE;
    field.value = this.getDateString();
    form.appendChild(field);

    field = document.createElement("INPUT");
    field.type="hidden";
    field.name = PARAM_TIME;
    field.value = this.formatTimeString(this.selectedStartTime);
    form.appendChild(field);

    field = document.createElement("INPUT");
    field.type="hidden";
    field.name = PARAM_END_TIME;
    field.value = this.formatTimeString(this.selectedEndTime);
    form.appendChild(field);

    field = document.createElement("INPUT");
    field.type="hidden";
    field.name = PARAM_LOCATION;
    for (var i=0; i<this.orderedItems.length; i++)
    {
        var item = this.orderedItems[i];
        if (item.type == T_RESOURCE)
        {
            if (this.selectedItems[item.id] != null)
            {
                field.value = item.location;
                break;
            }
        }
        else
            break; //no resource (resources should be at the top of the list)
    }
    form.appendChild(field);

    field = document.createElement("INPUT");
    field.type="hidden";
    field.name = "whence";
    field.value = window.location.href;
    form.appendChild(field);
};


nlScheduler.prototype.refresh = function ()
{
    if (this.bLoadedMinimized)
    {
        this.renderer.initLayout();
        
        
        this.renderer.showBusyIndicator(false);
        this.bLoadedMinimized = false;
   }
};


/*
 * toggle the selection of a time slot
 * the selected time slots has to be in the same day
 * If the time slot is not adjacent to existing time slots, the previous selected time slots will be removed
 */
nlScheduler.prototype.selectTimeSlot = function (dayIdx, timeIdx)
{
    //TODO update the selected date here using dayIdx for weekly view
    var size = this.getSizeOfSelectedItems();

    if (size == 0)
    {
        alert(ADD_PEOPLE_AND_RESOURCES);
        return;
    }

    var selectedStartTime = this.startTimeInMinutes + timeIdx * this.timeInterval;
    var selectedEndTime = selectedStartTime + this.timeInterval;

    // no time slot has been selected before
    if (this.selectedStartTime == null && this.selectedEndTime == null)
    {
        this.setSelectedTime(selectedStartTime, selectedEndTime);
        this.renderer.showSelectedTimeSlots(dayIdx, timeIdx, timeIdx, true);
        this.renderer.updateScheduleEventButton();
        return;
    }

    // unselect a boundary time slot
    if (this.selectedStartTime == selectedStartTime || this.selectedEndTime == selectedEndTime)
    {
        if (this.selectedStartTime == selectedStartTime)
            this.setSelectedTime(this.selectedStartTime + this.timeInterval, this.selectedEndTime);
        else
            this.setSelectedTime(this.selectedStartTime, this.selectedEndTime - this.timeInterval);

        if (this.selectedStartTime == this.selectedEndTime)
        {
            this.clearSelectedTime();
        }

        this.renderer.showSelectedTimeSlots(dayIdx, timeIdx, timeIdx, false);
    }
    // select an adjacent time slot to left
    else if (this.selectedStartTime == selectedEndTime)
    {
        this.setSelectedTime( this.selectedStartTime - this.timeInterval, this.selectedEndTime);
        this.renderer.showSelectedTimeSlots(dayIdx, timeIdx, timeIdx, true);
    }
    // select an adjacent time slot to right
    else if (this.selectedEndTime == selectedStartTime)
    {
        this.setSelectedTime( this.selectedStartTime, this.selectedEndTime + this.timeInterval);
        this.renderer.showSelectedTimeSlots(dayIdx, timeIdx, timeIdx, true);
    }
    // highlight the new time slots and remove previous selection
    else
    {
        // remove previous selection
        var selected = this.getSelectedTimeSlots();
        this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, false);

        // add new selection
        this.setSelectedTime(selectedStartTime,selectedEndTime);
        this.renderer.showSelectedTimeSlots(dayIdx, timeIdx, timeIdx, true);
    }
    this.renderer.updateScheduleEventButton();
};


/**
 * set the new date and update the availability
 * @param dateFieldId the calendar date field id
 */
nlScheduler.prototype.setNewDate = function (dateFieldId)
{
    var dateField = document.getElementById(dateFieldId);
    if (dateField == null)
        return;

    if (dateField.value == "")
    {
        this.renderer.showDate();
        return;
    }

    var date = stringtodate(dateField.value);
    if (date == this.selectedDate)
        return;

    this.setDate(date);

    this.clearSelectedTime();
    this.clearItemsAvailability();
    this.initCommonAvailability();
    this.renderer.showTimeSlotHeader();

    this.getAvailability(null, null, ACTION_NEW_DATE);
    this.renderer.showDate();
};

/**
 * Toggle the selection of a single item
 */
nlScheduler.prototype.toggleItemSelect = function (id)
{
    var item = this.items[id];
    var bAdd = true;

    if (this.getSelectedItem(id) == null)
    {
        // clear selected time slot header
        var selected = this.getSelectedTimeSlots();
        if (selected != null)
            this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, false);

        this.addSelectedItem(id);
    }
    else
    {
        this.removeSelectedItem(id);
        bAdd = false;
    }

    this.updateCommonAvailability(item, bAdd);

    var size = this.getSizeOfSelectedItems();

    if (size == 0 )
    {
        var selected = this.getSelectedTimeSlots();
        if (selected != null)
            this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, false);
        this.renderer.updateSelectAllCheckBox(false);
        this.toggleAllItemsSelect(false);
    }

    if (bAdd)     //add an item
    {
        this.updateSelectedTimeSlots(); // remove this to reset selected time when no item selected

        // show updated selected time slot header
        if (this.selectedStartTime != null && this.selectedEndTime != null)
        {
            var selected = this.getSelectedTimeSlots();
            this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, true);
        }
    }
    else
        // render the item without highlighted time blocks
        this.renderer.showItem(item);

    this.bAllItemsSelected = (this.getSizeOfSelectedItems() == this.getSizeOfItems());
    this.renderer.updateSelectAllCheckBox(this.bAllItemsSelected);


    this.renderer.showDraggedTimeSlots();
    this.renderer.showCommonAvailability();
    this.renderer.updateScheduleEventButton();
};


nlScheduler.prototype.toggleAllItemsSelect = function (bSelectAll)
{
    if (this.getSizeOfItems() == 0 || bSelectAll == false)
    {
        this.bAllItemsSelected = false;
        this.renderer.updateSelectAllCheckBox(false /*uncheck*/);
        return;
    }

    var selected = this.getSelectedTimeSlots();
    if (selected != null)
        this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, false /*hightlight*/);

    this.initCommonAvailability();
    this.selectedItems = new Object();
    if (this.bAllItemsSelected)
    {
        this.bAllItemsSelected = false;
    }
    else
    {
        this.bAllItemsSelected = true;

        for (var key in this.items)
        {
            var item = this.items[key];
            this.selectedItems[item.id] = item;
            this.updateCommonAvailability(item, true);
        }
        this.updateSelectedTimeSlots();

        if (this.selectedStartTime != null && this.selectedEndTime != null)
        {
            var selected = this.getSelectedTimeSlots();
            this.renderer.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, true /*hightlight*/);
        }
    }

    this.renderer.showDraggedTimeSlots();
    this.renderer.showAllItemsSelectedState();
    this.renderer.showCommonAvailability();
    this.renderer.updateScheduleEventButton();
};



/**
 * Get the availability of a certain persone/group/resource
 * @param date queried date for availability
 * @param item the item to get availability
 * @param item the list of items to get availability, will be ignored if item is not null
 * @param action the action that triggers this availability request
 * @append whether to clear the current items
 */
nlScheduler.prototype.getAvailability = function (item, items, action)
{
    this.renderer.showBusyIndicator(true);
    this.pendingQueryGroupId = "";
    var path = "/app/crm/calendar/syncEventAvailability.nl?";
    var queryString = "xml=T&date=" + encodeURIComponent(getdatestring(this.selectedDate));

    if (item != null)  // add new item/group/resource
    {
        if (item.type == T_GROUP)
        {
            // only one attendee is allowed in one query for performance reason
            queryString += "&attendee=" + item.id;
            this.pendingQueryGroupId = item.id;   
        }
        else if (item.type == T_ENTITY)
        {
            queryString += "&entity0=" + item.id;
        }
        else if (item.type == T_RESOURCE)
        {
            queryString += "&resource=" + item.id;
        }
    }
    else  //update existing items/resources
    {
        if (items == null)
            items = this.items
        var entityIdx = 0;
        var resourceIdx = 0;
        for (var key in items)
        {
            var item = items[key];
            if (item != null)
            {
                if (item.type == T_ENTITY)
                {
                    queryString += "&entity" + entityIdx++ + "=" + item.id;
                }
                else if (item.type == T_RESOURCE)
                {
                    queryString += "&resource" + resourceIdx++ + "=" + item.id;
                }
            }
        }
    }

    queryString = queryString + "&t=" + (new Date().getTime());
    var async = true;

    nlXMLRequestURL( path + queryString, null, null, new Function ("response", "window." + this.htmlId + ".addItems(response, " + action + ");"), async);
 };

/***************************************************************
scheduler internal functions
***************************************************************/

nlScheduler.prototype.init = function ()
{
    this.clearSelectedTime();

    this.clearItems();

    this.bAllItemsSelected = false;

    // a work arround for element not found js error
    var form = document.getElementById("main_form");
    if (form!= null)
    {
        var elem = document.getElementById("id");
        if (elem == null)
            elem = document.createElement("INPUT");
        elem.type = "hidden";
        elem.id = "id";
        elem.value = "-1";
        form.appendChild(elem);
    }

    this.renderer.initLayout();
};

nlScheduler.prototype.addEventHandlers = function ()
{
    this.addDragEventHandlers();
};

nlScheduler.prototype.addDragEventHandlers = function ()
{
    var htmlId = this.htmlId;
    attachEventHandler("mouseup", document, function(evnt){if (window[htmlId]){window[htmlId].handleMouseUp(evnt);}});
    attachEventHandler("mousemove", document, function(evnt){if (window[htmlId]){window[htmlId].handleMouseMove(evnt);}});
    attachEventHandler("resize", document, function(evnt){if (window[htmlId]){window[htmlId].handleResize(evnt);}});
};

/**
 * add event listener for drag div
 */
nlScheduler.prototype.addDragDivEventHandlers = function (dragDiv)
{
    var htmlId = this.htmlId;
    attachEventHandler("mouseup", dragDiv, function(evnt){if (window[htmlId]){window[htmlId].handleMouseUp(evnt);}});
    attachEventHandler("mousedown", dragDiv, function(evnt){if (window[htmlId]){window[htmlId].handleMouseDown(evnt);}});
    attachEventHandler("mousemove", dragDiv, function(evnt){if (window[htmlId]){window[htmlId].handleMouseMove(evnt);}});
};

/**
 *   The user starts to drag the poitlet.
 */
nlScheduler.prototype.handlePortletDrag= function ()
{
    this.renderer.handlePortletDrag();
};


/**
 * reposition the dragdiv when the user drop the poitlet.
 */
nlScheduler.prototype.handlePortletDrop = function ()
{
    this.renderer.handlePortletDrop();
};

/**
 * reposition the dragdiv when the user maximize the poitlet.
 */
nlScheduler.prototype.handlePortletMax = function ()
{
    this.bMinimized = false;
    if (this.bLoadedMinimized)
        this.refresh();
    else
        this.renderer.handlePortletMax();
};

/**
 * indicate the poitlet is minimized.
 */
nlScheduler.prototype.handlePortletMin = function ()
{
    this.bMinimized = true;
};

/**
 * Move the dragdiv when the user drags the poitlet.
 */
nlScheduler.prototype.handlePortletMove = function ()
{
    this.renderer.handlePortletMove();
};


nlScheduler.prototype.handleMouseDown = function (evnt)
{
    var elem = getEventTarget(evnt);
    if (this.getSizeOfSelectedItems() == 0)
    {
        this.mouseDown = false;
        return true;
    }

    var leftSlider = document.getElementById(this.renderer.getLeftSliderId());
    var rightSlider = document.getElementById(this.renderer.getRightSliderId());
    if (this.isInside(elem, leftSlider))
    {
        this.bLeftSlider = true;
        this.mouseDown = true;

    }
    else if (this.isInside(elem, rightSlider))
    {
        this.bLeftSlider = false;
        this.mouseDown = true;
    }
    else
        this.mouseDown = false;

    if (this.mouseDown == true)
    {
        this.origDragStartTimeIdx = this.dragStartTimeIdx;
        this.origDragEndTimeIdx = this.dragEndTimeIdx;
        this.origDragDayIdx = this.dragDayIdx;
    }

    evnt.cancelBubble = true;
    evnt.returnValue = false;
    return false;
};

/**
 * Show the drag div over available time slots
 */
nlScheduler.prototype.handleMouseMove = function (evnt)
{
    if (this.mouseDown != true)
        return true;

    var timeIdx;
    var dayIdx;

    var elem = getEventTarget(evnt);
    if (this.isInsideItemTimeSlotCell(elem))
    {   // the div inside time slot cell
        var tmp = elem.id.split("_");
        if (elem.tagName == "TD")
        {
            timeIdx = tmp[tmp.length - 1] * 1;
            dayIdx = tmp[tmp.length - 2] * 1;
        }
        //window.status = timeIdx;
        else
        {   // inside the div
            timeIdx = tmp[tmp.length - 2] * 1;
            dayIdx = tmp[tmp.length - 3] * 1;
        }
    }
    else if (this.isInside(elem, this.renderer.dragDiv))
    {
        if(this.timeSlotWidths == null)
            this.calculateTimeSlotWidths();

        var offsetX = this.getOffsetInside(elem, this.renderer.dragDiv).x + this.getOffsetXInElem(evnt);
        timeIdx = this.getTimeSlotFromOffset(offsetX);
        dayIdx = this.dragDayIdx;
    }
    else
        return true;

    //schedule an event with time conflict is not allowed.
    //if (!this.isTimeSlotAvailable(dayIdx, timeIdx))
    //    return;


    var oldDragStartTimeIdx = this.dragStartTimeIdx;
    var oldDragEndTimeIdx = this.dragEndTimeIdx;
    var oldDragDayIdx = this.dragDayIdx;

    // dragg and expand left
    if(timeIdx < this.dragStartTimeIdx)
    {
        this.dragStartTimeIdx = timeIdx;
    }
    // dragging and expand right
    else if (timeIdx > this.dragEndTimeIdx)
    {
        this.dragEndTimeIdx = timeIdx;
    }
    else
    {
        // shrink the selection
        if (this.dragStartTimeIdx != this.dragEndTimeIdx)
        {
            if (this.bLeftSlider)
                this.dragStartTimeIdx = timeIdx;
            else
                this.dragEndTimeIdx = timeIdx;
        }
    }


    if (oldDragDayIdx!= null && oldDragStartTimeIdx != null && oldDragEndTimeIdx != null)
        this.renderer.highLightTimeSlotHeaderCells(oldDragDayIdx, oldDragStartTimeIdx, oldDragEndTimeIdx, false /*highlight*/);

    var selectedStartTime = this.startTimeInMinutes + this.dragStartTimeIdx * this.timeInterval;
    var selectedEndTime = this.startTimeInMinutes + (this.dragEndTimeIdx + 1) * this.timeInterval;
    this.setSelectedTime(selectedStartTime, selectedEndTime);

    this.renderer.highLightTimeSlotHeaderCells(this.dragDayIdx, this.dragStartTimeIdx, this.dragEndTimeIdx, true /*highlight*/);
    this.renderer.showDraggedTimeSlots();
    this.renderer.showTime (selectedStartTime, selectedEndTime);

    evnt.returnValue = false;
    evnt.cancelBubble = true;
    return false;
};

/**
 * Calculate the width of each time slot and store the values
 * This is not needed when all time slots have equal width
 */
nlScheduler.prototype.calculateTimeSlotWidths = function ()
{
    this.timeSlotWidths = new Array();
    var elem = this.orderedItems[0];
    var id = elem.id;

    for (var i=0; i< this.numTimeSlots; i++)
    {
        var cell = document.getElementById(this.renderer.getItemTimeSlotCellId(id, this.dragDayIdx, i));
        this.timeSlotWidths[i] = cell.offsetWidth;
    }
};

/**
 *  Calculate the time slot index based on the offset of mouse inside the div
 */
nlScheduler.prototype.getTimeSlotFromOffset = function (offsetX)
{
    var offset = 0;
    for (var i = this.dragStartTimeIdx; i <= this.dragEndTimeIdx; i++)
    {
        offset += this.timeSlotWidths[i];
        if (offset >= offsetX)
            break;
    }
    return i;
};

/**
 * get the mouse x offset inside an element
 */
nlScheduler.prototype.getOffsetXInElem = function (evnt)
{
    return evnt.offsetX == undefined ? evnt.layerX : evnt.offsetX;
};

/**
 * Update the selected time slots, hide the drag div
 */
nlScheduler.prototype.handleMouseUp = function (evnt)
{
    if (this.mouseDown != true)
        return true;

    //this.renderer.hideDraggedTimeSlots();

    if (this.origDragStartTimeIdx != null && this.origDragEndTimeIdx != null && this.origDragDayIdx != null)
        this.renderer.showSelectedTimeSlotCells(this.origDragDayIdx, this.origDragStartTimeIdx, this.origDragEndTimeIdx, false /*show*/);


    this.renderer.showSelectedTimeSlotCells(this.dragDayIdx, this.dragStartTimeIdx, this.dragEndTimeIdx, true /*show*/);

    this.mouseDown = false;

    evnt.cancelBubble = true;
    evnt.returnValue = false;
    return false;
};

nlScheduler.prototype.handleResize = function (evnt)
{
    this.renderer.resize();
};


nlScheduler.prototype.isInsideItemTimeSlotCell = function (elem)
{
    if (elem.id == "undefined" || elem.id == null)
        return false;

    if (elem.id.indexOf("item_ts_") == -1 || elem.id.indexOf("_fill") != -1)
        return false;

    return true;
};

/**
 * Get the offset of an element in side a container object
 * make sure the element is contained in the element first.
 */
nlScheduler.prototype.getOffsetInside = function (elem, containerObj)
{
    var offset = {};
    offset.x = 0;
    offset.y = 0;
    while(elem != containerObj)
    {
        offset.x += elem.offsetLeft;
        offset.y += elem.offsetTop;
        if (elem.parentNode != null)
            elem = elem.parentNode;
        else if(elem.parentWindow != null)
            elem = elem.parentWindow.document;
    }
    return offset;
};

nlScheduler.prototype.isInside = function (elem, containerObj)
{
    return ((elem == containerObj) || (jQuery(containerObj).find(elem).length > 0));
};

/**
 * mark a certain time slot of the entity/resource as not available
 * @param item the etity/resource object
 * @param dayIdx the zero based sequence number of the day in the week
 * @param event the event object that contains a scheduled event in the day given
 */
nlScheduler.prototype.setItemAvailability = function (item, dayIdx, event)
{
    var status = event.getElementsByTagName('response')[0].firstChild.nodeValue;
    var startTimeStr = event.getElementsByTagName('starttimestr')[0].firstChild.nodeValue;
    var endTimeStr = event.getElementsByTagName('endtimestr')[0].firstChild.nodeValue;
    var startTime = event.getElementsByTagName('starttime')[0].firstChild.nodeValue;
    var endTime = event.getElementsByTagName('endtime')[0].firstChild.nodeValue;

    startTime = Math.max(this.parseToMinutes (startTime), this.startTimeInMinutes);
    endTime = Math.min(this.parseToMinutes (endTime), this.endTimeInMinutes);
    if (endTime <= startTime)
        return;

    var startTimeSlot = Math.floor((startTime - this.startTimeInMinutes) / this.timeInterval);
    var endTimeSlot = Math.floor ((endTime -1 - this.startTimeInMinutes) / this.timeInterval);
    endTimeSlot = endTimeSlot >= this.numTimeSlots ? this.numTimeSlots - 1 : endTimeSlot;

    var permLevel = 0;
    if (event.getElementsByTagName('permLevel')[0] != null)
        permLevel = event.getElementsByTagName('permLevel')[0].firstChild.nodeValue;

    var tooltip = null;
    if (permLevel >= 2)
    {
        var title="";
        if (event.getElementsByTagName('title')[0] != null)
            title = event.getElementsByTagName('title')[0].firstChild.nodeValue;
        var location = "";
        if (event.getElementsByTagName('location')[0] != null)
            location = event.getElementsByTagName('location')[0].firstChild.nodeValue;
        var organizer = event.getElementsByTagName('organizer')[0].firstChild.nodeValue;
        tooltip =  TITLE + ": " +  title.replace(/'/g,"\\'") + "<br/>" + LOCATION + ": " + location.replace(/'/g,"\\'") + "<br/>" + TIME + ": " + startTimeStr + " - " + endTimeStr + "<br/>" + ORGANIZER + ": " + organizer.replace(/'/g,"\\'");
    }

    item.setAvailablity(dayIdx, startTimeSlot, endTimeSlot, status, tooltip);
    //this.setCommonAvailability(dayIdx, startTimeSlot, endTimeSlot, false);
};


/**
 * test if a certain time slot of the entity/resource is available
 * @param item the etity/resource object
 * @param dayIdx the zero based sequence number of the day in the week
 * @param timeIdx the zero based time slot index of the day
 */
nlScheduler.prototype.isItemAvailable = function (item, dayIdx, timeIdx)
{
    if ( typeof item.timeSlot[dayIdx] == "undefined" || item.timeSlot[dayIdx] == null)
        return true;

    else if (item.timeSlot[dayIdx][timeIdx] == "ACCEPTED" || item.timeSlot[dayIdx][timeIdx] == "TENTATIVE" || item.timeSlot[dayIdx][timeIdx] == "NORESPONSE")
        return false;

    return true;
};

nlScheduler.prototype.clearItems = function ()
{
    this.items = new Object();     //item map
    this.orderedItems = new Array();      //iem array
    this.selectedItems = new Object();
    this.initCommonAvailability();
    this.numResources = 0;
};


nlScheduler.prototype.clearItemsAvailability = function ()
{
    for (var key in this.items)
    {
        if (this.items[key] != "undefined" && this.items[key] != null)
            this.items[key].clearAvailability();
    }
};

nlScheduler.prototype.getDateIndexInWeek = function (date)
{
    return 0;
};

/**
 * Include an item (entity or resource) to create a new event
 */
nlScheduler.prototype.addSelectedItem = function ( id )
{
    if (this.items[id] != null)
        this.selectedItems[id] = this.items[id];
};

/**
 * Remove an item (entity or resource) to create a new event
 */
nlScheduler.prototype.removeSelectedItem = function ( id )
{
    this.selectedItems[id] = null;
};

nlScheduler.prototype.getSelectedItem = function ( id )
{
    if (typeof this.selectedItems[id] == "undefined" || this.selectedItems[id] == null)
        return null;

    return this.selectedItems[id];
};

nlScheduler.prototype.isItemSelected = function ( id )
{
    if (typeof this.selectedItems[id] != "undefined" && this.selectedItems[id] != null)
        return true;
    return false;
};

nlScheduler.prototype.getSizeOfSelectedItems = function ()
{
    return this.getSizeOfMap(this.selectedItems);
};

nlScheduler.prototype.getSizeOfItems = function ()
{
    return this.orderedItems.length;
};

nlScheduler.prototype.getSizeOfMap = function (map)
{
    var size = 0;
    for (var key in map)
    {
        if (map[key] != "undefined" && map[key] != null)
            size++;
    }
    return size;
};

/**
 * Intialize the data structure for common availability info
 */
nlScheduler.prototype.initCommonAvailability = function ()
{
    this.commonAvailability = new Array();

    for (var i = 0; i < this.numDays; i++)
    {
        if (this.commonAvailability[i] == null)
            this.commonAvailability[i] = new Array();

        for (var j =0; j < this.numTimeSlots; j++)
        {
            this.commonAvailability[i][j] = 0;
        }
    }
};

/**
 * update the common availability info for the given day and time slot
 * If the time slot is available, the value for the day and time slot should be 0;
 */
nlScheduler.prototype.isTimeSlotAvailable = function (dayIdx, timeSlotIdx)
{
    return (this.commonAvailability [dayIdx][timeSlotIdx] == 0);
};


/**
 * update the common availability info for the given day and time slot
 * If the time slot is available, the value for the day and time slot should be 0;
 */
nlScheduler.prototype.setCommonAvailability = function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, bAvail)
{
    for (var i = startTimeSlotIdx; i <= endTimeSlotIdx; i++)
    {
        if (!bAvail)
            this.commonAvailability [dayIdx][i]++;
        else
        {
            if (this.commonAvailability [dayIdx][i] > 0)
                this.commonAvailability [dayIdx][i]-- ;
        }
    }

};

/**
 * update the common availability based on the addition or removal of an item
 * @param bSelected whether the item is selected or removed from the selected list
 */
nlScheduler.prototype.updateCommonAvailability = function (item, bSelected)
{
    for (var i = 0; i < this.numDays; i++)
    {
        for (var j = 0; j < this.numTimeSlots; j++)
        {
            if ((typeof item.timeSlot[i] != "undefined" && item.timeSlot[i] != null) &&
                (typeof item.timeSlot[i][j] != "undefined" && item.timeSlot[i][j] != null))
            {
                if (item.timeSlot[i][j] == "ACCEPTED" || item.timeSlot[i][j] == "TENTATIVE"|| item.timeSlot[i][j] == "NORESPONSE")
                {
                    if (bSelected)
                        this.commonAvailability[i][j]++;
                    else if (this.commonAvailability[i][j] > 0)
                        this.commonAvailability[i][j]--;
                }
            }
        }
    }
};

nlScheduler.prototype.setDate = function (date)
{
    this.selectedDate = date;
};

nlScheduler.prototype.clearSelectedTime = function ()
{
    this.selectedStartTime = null;
    this.selectedEndTime = null;

    this.dragStartTimeIdx = null;
    this.dragEndTimeIdx = null;
    this.dragDayIdx = 0;
};

nlScheduler.prototype.setSelectedTime = function (start, end, day)
{
    if (start != null)
    {
        this.selectedStartTime  = start;
        this.dragStartTimeIdx = Math.floor((this.selectedStartTime - this.startTimeInMinutes) / this.timeInterval);

    }
    if (end != null)
    {
        this.selectedEndTime  = end;
        this.dragEndTimeIdx =Math.floor ((this.selectedEndTime - 1 - this.startTimeInMinutes) / this.timeInterval);
    }
};


/**
 * Calculate selected time slots from start and end time
 * returns an object that has dayIdx, startTimeIdx and endTimeIdx.
 * returns null if no time slot selected
 */
nlScheduler.prototype.getSelectedTimeSlots = function()
{
    var curStartTimeSlot = null;
    var curEndTimeSlot = null;
    var obj = null;

    if (this.selectedDate != null && this.selectedStartTime != null && this.selectedEndTime != null)
    {
        curStartTimeSlot = Math.floor((this.selectedStartTime - this.startTimeInMinutes) / this.timeInterval);
        curEndTimeSlot = Math.floor ((this.selectedEndTime - 1 - this.startTimeInMinutes) / this.timeInterval);

        var obj = new Object();
        obj.dayIdx = 0;
        obj.startTimeIdx = curStartTimeSlot;
        obj.endTimeIdx = curEndTimeSlot;
    }



    this.dragDayIdx = 0;
    this.dragStartTimeIdx = curStartTimeSlot;
    this.dragEndTimeIdx = curEndTimeSlot;

    return obj;
};


/**
 * Update the selected time based on the common availability
 * This is usually called when an new item is selected.
 */
nlScheduler.prototype.updateSelectedTimeSlots = function ()
{
    if (this.getSizeOfSelectedItems() == 0)
    {
        this.clearSelectedTime();
        return;
    }

    var dayIdx = this.getDateIndexInWeek();

    var newStartTimeSlot = -1;
    var newEndTimeSlot = -1;

    // no time slot selected, pick the first available one
    if (this.selectedStartTime == null)
    {
        for (var i = 0; i < this.numTimeSlots; i++)
        {
            if (this.commonAvailability[dayIdx][i] == 0)
            break;
        }
        if (i < this.numTimeSlots)
        {
            newStartTimeSlot = i;
            newEndTimeSlot = i;
        }
    }
    else
    {
        var curStartTimeSlot = Math.floor((this.selectedStartTime - this.startTimeInMinutes) / this.timeInterval);
        var curEndTimeSlot = Math.floor ((this.selectedEndTime -1 - this.startTimeInMinutes) / this.timeInterval);

        newStartTimeSlot = curStartTimeSlot;
        newEndTimeSlot = curEndTimeSlot;
    }

    if (newStartTimeSlot >= 0)
    {
        this.setSelectedTime (newStartTimeSlot * this.timeInterval + this.startTimeInMinutes,
                              (newEndTimeSlot + 1) *  this.timeInterval + this.startTimeInMinutes);
    }
    else
        this.clearSelectedTime();
};


/**
  *  Get the date string in format accepted by the server.
  *  This is not localized string, for event creation only
  */
nlScheduler.prototype.getDateString = function ()
{
    return (this.selectedDate.getMonth() + 1) + "/" + this.selectedDate.getDate() + "/" + this.selectedDate.getFullYear();
};

/**
 * Parse a time string and return the number of minutes from the starting of the day
 * @param time a string represents time in format hh:mm (am/pm)
 * return the number of minutes from the starting of the day
 * return -1 if the string format is invalid
 */
nlScheduler.prototype.parseToMinutes = function (time)
{
    if (time == "undefined" || time == null || time == "")
        return -1;

    time = time.toLowerCase();

    var timeArray = time.split(":");
    if (timeArray[0].trim() == "12")
        timeArray[0] = "0";

    var minutes;
    var idx = timeArray[1].indexOf("pm");
    if (idx != -1)
    {
        timeArray[1] = timeArray[1].substring(0, idx).trim();
        minutes = (timeArray[0].trim() * 1 + 12) * 60 + timeArray[1] * 1;
    }
    else
    {
        idx = timeArray[1].indexOf("am");
        if (idx != -1)
        {
           timeArray[1] = timeArray[1].substring(0, idx).trim();
        }
        minutes = timeArray[0].trim() * 60 + timeArray[1] * 1;
    }

    return minutes;
};

/**
 * Create a time string in format hhmm
 * @param time in minutes
 */
nlScheduler.prototype.formatTimeString = function (time)
{
    var hour = Math.floor (time/60) ;
    var minute = time%60;
    if (minute < 10)
        minute = "0" + minute;

    return hour + "" + minute;
};

/**
 * Load scheduler state
 * @param time in minutes
 */
nlScheduler.prototype.loadState = function ()
{
    /*
    var queryString = this.portletUrl + "&" + "action" + "=" + "load";
    var async = true;

    nlXMLRequestURL( path + queryString, null, null, async, new Function ("response", "window." + this.htmlId + ".restoreState(response);"));
    */
};


/**
 * Save scheduler state
 * @param time in minutes
 */
nlScheduler.prototype.restoreState = function (response)
{
    /*
    var sText = response.getBody();
    if (sText == null || sText == "")
        return;

    var stateArray = sText.split();
    */
};


/**
 * Save scheduler state
 * @param time in minutes
 */
nlScheduler.prototype.saveState = function (evnt)
{
    var queryString = this.portletUrl + "&action=save&state=" + this.groupId + "&t=" + (new Date().getTime());
    var async = true;

    nlXMLRequestURL( queryString, null, null, null, async);
};


function nlItem(scheduler)
{
    this.clearAvailability();
    this.owner = scheduler;
}

nlItem.prototype.clearAvailability = function()
{
    this.timeSlot = new Array();
    this.tooltip = new Array();
};

nlItem.prototype.setAvailablity = function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, status, tooltip)
{
    if (this.timeSlot[dayIdx] == null)
        this.timeSlot[dayIdx] = new Array();

    if (this.tooltip[dayIdx] == null)
        this.tooltip[dayIdx] = new Array();

    for (var i = startTimeSlotIdx; i <= endTimeSlotIdx; i++)
    {
        this.timeSlot[dayIdx][i] = status;
        // TODO append overlapping tooltip here
        this.tooltip[dayIdx][i] = tooltip;
    }
};

function nlSchedulerRenderer (scheduler)
{
    this.owner = scheduler;

    this.tableDivId = "div_" + this.owner.id;
    this.calendarFieldId = null;
    this.padding = "padding:0px 3px 0px 3px";
    this.table = new nlTable(this.owner.id, this.tableDivId, 3, 1);

    //calculate the lable cutoff length
    switch (TEXT_SCALE)
    {
        case 1.25:
            this.itemNameMaxLength = 14;
            break;
        case 1.5:
            this.itemNameMaxLength = 10;
            break;
        case 1.0:
        default:
            this.itemNameMaxLength = 16;
            break;
    }
}


nlSchedulerRenderer.prototype.renderLayout = function()
{

};

/**
 * set the control ids used in the scheduler
 */
nlSchedulerRenderer.prototype.setControlIds  = function (calendarFieldId)
{
    if(typeof calendarFieldId != "undefined" &&  calendarFieldId != null)
    {
        this.calendarFieldId = calendarFieldId;
    }
};

/**
 * show all items as selected or unselected
 */
nlSchedulerRenderer.prototype.showAllItemsSelectedState = function ()
{
    for (var key in this.owner.items)
    {
        var item = this.owner.items[key];

        var elem = document.getElementById(this.getItemSelectCheckBoxId(item.id));

        setFormValue(elem,this.owner.isItemSelected(item.id));
    }
};

/**
 * show an item as selected or unselected
 */
nlSchedulerRenderer.prototype.showItemAsSelected = function (id, bSelected)
{
    var elem = document.getElementById(this.getItemSelectCheckBoxId(id));
    if (elem != null)
        setFormValue(elem, bSelected);
};

/**
 * update select alll checkbox as selected or unselected
 */
nlSchedulerRenderer.prototype.updateSelectAllCheckBox = function (bSelected)
{
    var elem = document.getElementById(this.getSelectAllCheckBoxId());
    setFormValue(elem, bSelected);
};

/*
 * show the common availability bar
 */
nlSchedulerRenderer.prototype.showCommonAvailability = function()
{
    var header = document.getElementById(this.getCommonAvailabilityDivId());
    if (header == null)
    {
        header = document.createElement("SPAN");
        header.id = this.getCommonAvailabilityDivId();
        var headerRow = document.getElementById(this.getCommonAvailabilityRowId());
        headerRow.appendChild(header);
    }

    removeAllChildren(header);

    for (var i=0; i<this.owner.numDays; i++)
    {
        for (var j=0; j<this.owner.numTimeSlots; j++)
        {
            var td = document.createElement("TD");
            td.id = this.getCommonAvailabilityCellId(i, j);
			td.className = 'common-availability';

	        if (this.owner.getSizeOfSelectedItems() != 0)
		        td.classList.add('common-availability--'+(this.owner.commonAvailability[i][j] == 0 ? 'available' : 'unavailable'));

            header.appendChild(td);
        }
    }
    var td = document.createElement("TD");
    td.id = this.getCommonAvailabilityCellId(i, j) + "_fill";
	td.className = 'common-availability common-availability-fill'
    td.colSpan= 2;
    header.appendChild(td);

    //header.innerHTML = htmlStr.join("");
};

/**
 *  Show the initial layout
 */
nlSchedulerRenderer.prototype.initLayout = function()
{
    if (this.owner.bMinimized)
        return;

    this.table.init();
    this.table.showInitLayout();
    this.dragDiv = null;
    this.customizeLayout();
    this.showDateControls();
    this.showTimeSlotHeader();
    this.showCommonAvailability();
    this.showItems(true);
    this.showDate();
    if (this.owner.selectedStartTime != null && this.owner.selectedEndTime != null)
    {
        var selected = this.owner.getSelectedTimeSlots();
        this.showSelectedTimeSlots(selected.dayIdx, selected.startTimeIdx, selected.endTimeIdx, true /*hightlight*/);
    }
    this.updateSelectAllCheckBox(this.owner.bAllItemsSelected);

    
    this.table.setFixedColumnsBlockWidth();
    
};


nlSchedulerRenderer.prototype.showBusyIndicator = function (bShow)
{
    var elem = document.getElementById(this.getBusyIndicatorId());

    if (elem == null)
        return;

    if (bShow == false)
        elem.style.visibility = "hidden";
    else
         elem.style.visibility = "visible";
};
/**
*  customize the layou for the scheduler
*/
nlSchedulerRenderer.prototype.customizeLayout = function ()
{
    var scrollingHeaderElem = this.table.getScrollingHeaderElem();
    var htmlStr = new Array();
    htmlStr[htmlStr.length] = "<table cellspacing=0 cellpadding=0 width=100%>";
    htmlStr[htmlStr.length] = "<tr id='" + this.getTimeSlotHeaderDivId() + "'>";
    htmlStr[htmlStr.length] = "</tr>";
    htmlStr[htmlStr.length] = "<tr id='" + this.getCommonAvailabilityDivId() + "'>\n";
    htmlStr[htmlStr.length] = "</tr>";
    htmlStr[htmlStr.length] = "</table>";

    scrollingHeaderElem.innerHTML = htmlStr.join("");
};

/**
 *  show the select all check box, the prev/next day button and the date control
 */
nlSchedulerRenderer.prototype.showDateControls = function ()
{
    var dateElem = this.table.getFixedColumnsHeaderElem();
    var htmlStr = new Array();
    htmlStr[htmlStr.length] = "<div class='scheduler-header-controls'>\n";
    htmlStr[htmlStr.length] = "<span style='top:0;' class='checkbox_unck' id='check_" + this.owner.id + "_fs' onclick='NLCheckboxOnClick(this);' style='white-space: nowrap; padding-bottom: 0px;'><input id='check_" + this.owner.id + "' type='checkbox' class='checkbox uir-check-box' onChange='NLCheckboxOnChange(this);' onclick='javascript:toggleAllItemsSelect(\"" + this.owner.id + "\", \"check_" + this.owner.id + "\");'/><img class='checkboximage' src='/images/nav/ns_x.gif' alt=''></span>\n";
    /*
    * TODO: after refactor this date picker remove the selector from the input.css and use the unify way of hover over datepicker
    */
    var dateControlStr = window["datefield_" + this.owner.id + "_html"];
    dateControlStr = dateControlStr.replace(/&gt;/g,">");
    dateControlStr = dateControlStr.replace(/&lt;/g,"<");
    htmlStr[htmlStr.length] = dateControlStr;
	htmlStr[htmlStr.length] = "<a href='javascript:void(0);' onclick='javascript:changeDate(\"" + this.owner.id + "\", \"" + this.getDateControlId() + "\", false);return false;'>";
	htmlStr[htmlStr.length] = "<img class='iArrowLeft' src='/images/nav/ns_x.gif' align='middle' border='0' alt='Previous day'>";
	htmlStr[htmlStr.length] = "</a>\n";
    htmlStr[htmlStr.length] = "<a href='javascript:void(0);' onclick='javascript:changeDate(\"" + this.owner.id + "\", \"" + this.getDateControlId() + "\", true);return false;'>";
    htmlStr[htmlStr.length] = "<img class='iArrowRight' src='/images/nav/ns_x.gif' align='middle' border=0 alt='Next day'>";
    htmlStr[htmlStr.length] = "</a>\n";
    htmlStr[htmlStr.length] = "</div>";

    dateElem.innerHTML = htmlStr.join("");
};


nlSchedulerRenderer.prototype.showTimeSlotHeader = function()
{
    var header = document.getElementById(this.getTimeSlotHeaderDivId());
    if (header == null)
    {
        header = document.createElement("SPAN");
        header.nowrap = "nowrap";
        header.id = this.getTimeSlotHeaderDivId();
        var headerRow = document.getElementById(this.getTimeSlotHearderRowId());
        headerRow.appendChild(header);
    }

    removeAllChildren(header);

    for (var i=0; i<this.owner.numDays; i++)
    {
        for (var j=0; j<this.owner.numTimeSlots; j++)
        {
            var label = this.getTimeString(j*this.owner.timeInterval+this.owner.startTimeInMinutes, false, false);
            var td = document.createElement("TD");
            td.id = this.getTimeSlotHearderCellId(i, j);
			td.className = 'time-slot-header-cell';
            td.innerHTML = "<a class='textnolink' href=\"javascript:void(0);\" onclick=\"selectTimeSlot('" + this.owner.id + "', " + i + ", " + j + "); return false\">" + label + "</a>";
            header.appendChild(td);
        }
    }

    var td = document.createElement("TD");
    td.id = this.getTimeSlotHearderCellId(i, j) + "_fill";
	td.className = 'time-slot-header-cell time-slot-header-fill-cell';
    header.appendChild(td);
    td = document.createElement("TD");
    td.id = this.getTimeSlotHearderCellId(i, j) + "_fill_scrollbar";   //leave space for vertical scroll bar
	td.className = 'time-slot-header-cell time-slot-header-scrollbar-cell';
    header.appendChild(td);
};

/**
 * highlight or de-highlight time slot header cells
 * @param dayIdx day index
 * @param startTimeSlotIdx the starting index of the time slots
 * @param endTimeSlotIdx the end index of the time slots
 * @param bHighLight highlight or not
 */
nlSchedulerRenderer.prototype.highLightTimeSlotHeaderCells = function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, bHighLight)
{
    for (var i=startTimeSlotIdx; i<=endTimeSlotIdx; i++)
    {
        var header = document.getElementById(this.getTimeSlotHearderCellId (dayIdx, i));
        header.style.borderStyle = bHighLight ? "inset" : "outset" ;
    }
};

/**
 * Update the date for both calendar date field and the date label field (at the bottom)
 * @param calendarFieldId calendar date field
 */
nlSchedulerRenderer.prototype.showDate = function(calendarFieldId, date)
{
    var dateStr;
    if (typeof date == "undefined" || date == null)
        date = this.owner.selectedDate;

     dateStr = getdatestring (date);

    // update the calendar field;
    var dateField = document.getElementById(this.getDateControlId());
    if (dateField != null)
        dateField.value = dateStr;

    // update the date label field;
    dateField = document.getElementById(this.getDateLabelId());

    var dayOfWeekStr = NLDate_short_days[date.getDay()];

    //TODO the format is not localized due to js limitations.
    dateField.innerHTML = dayOfWeekStr + "&nbsp;" + dateStr;
};

/**
 * Update the time label field (at the bottom)
 */
nlSchedulerRenderer.prototype.showTime = function(startTime, endTime)
{
    var timeStr;
    var curStartTime;
    var curEndTime;
    if(startTime != "undefined" && startTime != null &&
       endTime != "undefined" && endTime != null)
    {
        curStartTime = startTime;
        curEndTime = endTime;
    }
    else
    {
        curStartTime = this.owner.selectedStartTime;
        curEndTime = this.owner.selectedEndTime;
    }

    if (curStartTime == null || curEndTime == null)
        timeStr = "";
    else
        timeStr = this.getTimeString(curStartTime, false/*24h*/, true/*am pm*/) +
                  "&nbsp;-&nbsp;" +
                  this.getTimeString(curEndTime, false/*24h*/, true/*am pm*/);

    // update the time field;
    var timeField = document.getElementById(this.getTimeLabelId());
    if (timeField != null)
        timeField.innerHTML = timeStr;
};

/**
 * show all the items in the scheduler
 * @param bClearFlag whether to clear existing items
 */
nlSchedulerRenderer.prototype.showItems = function(bClearFlag)
{
    var bClear = bClear;

    var size = 0;
    var items = this.owner.orderedItems;

    if (items.length == 0)
    {
        items = new Array();
        for (var i = 0; i < 7; i++)
        {
            var item = new nlItem(this);
            item.id = "dummy_row_" + this.owner.id + "_" + i;
            item.name = "";
            item.type = "dummy";
            items[i] = item;
        }
        this.bDummyRows = true;
        bClear = true;
    }
    else
    {
        if (this.bDummyRows == true)
            bClear = true;
        this.bDummyRows = false;
    }

    if (bClear)
    {
        this.table.clearRows();
    }

    var item;
    for (var i = 0; i < items.length; i++)
    {
        item = items[i];
        if (item != "undefined" && item != null)
            this.showItem(item, i);
    }
};

/**
 * create the item layout
 */
nlSchedulerRenderer.prototype.createItem = function(item, pos)
{
    var bDummy = item.type == "dummy";

    var colIdx = 0;

    var row = this.table.addRow(item.id, null, pos);

    // show select item check box
    var htmlStr = "";
    if (!bDummy)
        htmlStr = "<span style='top:0;' class='checkbox_unck' id='check_" + this.owner.id + "_fs' onclick='NLCheckboxOnClick(this);' style='white-space: nowrap; padding-bottom: 0px;'><input type='checkbox' class='checkbox uir-check-box' id='" + this.getItemSelectCheckBoxId(item.id) + "' onclick='javascript:toggleItemSelect(\"" + this.owner.id + "\", \"" + item.id + "\"); return true;'/><img class='checkboximage' src='/images/nav/ns_x.gif' alt=''></span>";
    row.addCell(colIdx++, "", htmlStr, "item-checkbox-cell");

    // show image
    if (!bDummy)
    {
        htmlStr = "<img src='/images/nav/calendar/x.gif' class='resource-icon' data-type='" + item.type + "' alt='" + item.label + "'/>";
    }
    else
    {
        htmlStr = "";
    }
    row.addCell(colIdx++, "", htmlStr, "item-icon-cell");

	
	// show item name
    if (!bDummy)
    {
        var label = "";
        if (item.name.length >  this.itemNameMaxLength + 3)
		{
	        label = item.name.substring(0, this.itemNameMaxLength / 2) + "..." + item.name.substring(item.name.length - this.itemNameMaxLength / 2, item.name.length);
        }
		else
		{
	        label = item.name;
        }

        htmlStr = "<div title='" + item.name +  "' onclick='javascript:document.getElementById(\"" + this.getItemSelectCheckBoxId(item.id) + "\").click();'>" + label + "</div>";
    }
    else
        htmlStr = "";
    row.addCell(colIdx++, "", htmlStr, "item-label-cell");

    for (var i=0; i<this.owner.numDays; i++)
    {
        for (var j=0; j<this.owner.numTimeSlots; j++)
        {
            var id = this.getItemTimeSlotCellId(item.id, i, j);
            var tdContent = "<div id='" + id + "_d" + "' class='time-slot-content' onclick=\"selectTimeSlot('" + this.owner.id + "', " + i + ", " + j + "); return false;\"/>";
            var td = row.addCell(colIdx++, this.getItemTimeSlotCellId(item.id, i, j), tdContent, 'time-slot-cell');

            if ((item.timeSlot[i] != null && item.timeSlot[i] != "undefined") && item.timeSlot[i][j] == "ACCEPTED")
                td.dataset.state = SLOT_UNAVAILABLE;
            else if ((item.timeSlot[i] != null && item.timeSlot[i] != "undefined") && (item.timeSlot[i][j] == "TENTATIVE"|| item.timeSlot[i][j] == "NORESPONSE"))
            {
                td.dataset.state = SLOT_TENTATIVE;
            }
            else
	            td.dataset.state = SLOT_AVAILABLE;

            td.style.cellPadding = 0;
            td.style.cellSpacing = 0;

            if (item.tooltip[i] && item.tooltip[i][j])
            {
                var div = document.getElementById(id + "_d");
                div.onmouseover = esShowToolTip.bind(null, this.owner.id, item.tooltip[i][j]);
                div.onmouseout = esHideToolTip;
            }
         }
    }

    td = row.addCell(colIdx++, this.getItemTimeSlotCellId(item.id, i, j) + "_fill", "", "time-slot-fill-cell");
	td.dataset.state = SLOT_AVAILABLE;
 };

/**
 * Show an item, update availability if layout is available, otherwise, create new one
 */
nlSchedulerRenderer.prototype.showItem = function(item, pos)
{
    var itemElem = this.table.getRow(item.id);

    if (itemElem == null)   //create item
        this.createItem(item, pos);
    else
    {
        for (var i=0; i<this.owner.numDays; i++)
        {
            for (var j=0; j<this.owner.numTimeSlots; j++)
            {
                var td = document.getElementById(this.getItemTimeSlotCellId(item.id, i, j));
                if (item.timeSlot[i] && item.timeSlot[i][j] == "ACCEPTED")
				{
	                td.dataset.state = SLOT_UNAVAILABLE;
                }
				else if (item.timeSlot[i] && (item.timeSlot[i][j] == "TENTATIVE" || item.timeSlot[i][j] == "NORESPONSE"))
                {
	                td.dataset.state = SLOT_TENTATIVE;
                }
                else
                {
	                td.dataset.state =SLOT_AVAILABLE;
                }

                var id = this.getItemTimeSlotCellId(item.id, i, j);
                var div = document.getElementById(id + "_d");
                if (item.tooltip[i] && item.tooltip[i][j])
                {
	                div.onmouseover = esShowToolTip.bind(null, this.owner.id, item.tooltip[i][j]);
	                div.onmouseout = esHideToolTip;
                }
                else
                {
                    div.onmouseover = null;
                    div.onmouseout = null;
                }
            }
        }
    }

    this.showItemAsSelected(item.id, this.owner.isItemSelected(item.id));
};

/**
 * highlight or de-highlight item time slot cells
 * @param dayIdx day index
 * @param startTimeSlotIdx the starting index of the time slots
 * @param endTimeSlotIdx the end index of the time slots
 * @param bHighLight highlight or not
 */
nlSchedulerRenderer.prototype.showSelectedTimeSlotCells =  function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, bHighLight)
{
    for (var i=startTimeSlotIdx; i<=endTimeSlotIdx; i++)
    {
        var header = document.getElementById(this.getTimeSlotHearderCellId (dayIdx, i));
        header.style.borderStyle = bHighLight ? "inset" : "outset" ;

        for (var key in this.owner.selectedItems)
        {
            if (this.owner.getSelectedItem(key) != null)
            {
                var item = this.owner.selectedItems[key];
                if (this.owner.isItemAvailable(item, dayIdx, i))
                {
                    var cell = document.getElementById(this.getItemTimeSlotCellId(this.owner.selectedItems[key].id, dayIdx, i));
	                cell.dataset.state = bHighLight?SLOT_SELECTED:SLOT_AVAILABLE;
                }
            }
        }
    }
};

/**
 * highlight or de-highlight timeslots
 * @param dayIdx day index
 * @param startTimeSlotIdx the starting index of the time slots
 * @param endTimeSlotIdx the end index of the time slots
 * @param bHighLight highlight or not
 */
nlSchedulerRenderer.prototype.showSelectedTimeSlots = function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, bHighLight)
{
    this.showSelectedTimeSlotCells(dayIdx, startTimeSlotIdx, endTimeSlotIdx, bHighLight);
    this.showTime ();
    //todo show date for weekely view;

    this.showDraggedTimeSlots();
};

/**
 * The user starts to drag the poitlet.
 */
nlSchedulerRenderer.prototype.handlePortletDrag = function()
{
    if (!this.owner.bMinimized)
    {
        // the browser will uncheck all the checkboxes. Set their state again
        this.showAllItemsSelectedState();
        this.updateSelectAllCheckBox(this.owner.bAllItemsSelected);
    }
};

/**
 * reposition the dragdiv when the user drop the poitlet.
 */
nlSchedulerRenderer.prototype.handlePortletDrop = function()
{
    if (!this.owner.bMinimized)
    {
        if (document.getElementById(this.tableDivId)!=null)
            this.showDraggedTimeSlots();

        // the browser will uncheck all the checkboxes. Set their state again
        this.showAllItemsSelectedState();
        this.updateSelectAllCheckBox(this.owner.bAllItemsSelected);
    }
};


/**
 * reposition the dragdiv when the user maximize poitlet.
 */
nlSchedulerRenderer.prototype.handlePortletMax = function()
{
    this.handlePortletDrop();
};


/**
 * Move the dragdiv when the user drags the poitlet.
 */
nlSchedulerRenderer.prototype.handlePortletMove  = function()
{
    if (!this.owner.bMinimized)
    {
        if (document.getElementById(this.tableDivId)!=null)
            this.showDraggedTimeSlots();
        else
            // portlet is dragged in FF, it becomes hidden
            this.hideDraggedTimeSlots();
    }
};

/**
 * Show div over selected time slots
 * @param bShow whether to show the div or not
 */
nlSchedulerRenderer.prototype.showDraggedTimeSlots = function()
{
    var selected = this.owner.getSelectedTimeSlots();
    if (selected == null || this.owner.getSizeOfSelectedItems() == 0)
    {
        this.hideDraggedTimeSlots();
        return;
    }

    var schedulerDataAreaInnerDiv = document.getElementById(this.table.scrollingColumnsInnerDivBlockId);
    //calculate left
    var item = this.owner.orderedItems[0];
    var containerElem = document.getElementById(this.tableDivId);
    containerElem.nowrap = "nowrap";

    var elem = document.getElementById(this.getItemTimeSlotCellId(item.id, selected.dayIdx, selected.startTimeIdx));
    var left = elem.offsetLeft;

    item = this.owner.orderedItems[this.owner.orderedItems.length-1];
    elem = document.getElementById(this.getItemTimeSlotCellId(item.id, selected.dayIdx, selected.endTimeIdx));
    var right = elem.offsetLeft + elem.offsetWidth;

    this.dragdiv = document.getElementById(this.getDragDivId());
    if (!this.dragDiv)
    {
        this.dragDiv = document.createElement("DIV");
        schedulerDataAreaInnerDiv.appendChild(this.dragDiv);
		this.dragDiv.className = 'time-slot-dragger';
        this.dragDiv.id = "scroll_inner_dragDiv";
        this.owner.addDragDivEventHandlers (this.dragDiv);

        var table = document.createElement("TABLE");
        table.cellSpacing = 0;
        table.cellPadding = 0;
        this.dragDiv.appendChild(table);
        var tbody = document.createElement("TBODY");
        table.appendChild(tbody);

        var tr = document.createElement("TR");
        tr.height="100%";
        tbody.appendChild(tr);

        var td = document.createElement("TD");
        td.id = this.getLeftSliderId();
        td.onmousedown = new Function("return false;");
        td.style.cursor="e-resize";
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        td = document.createElement("TD");
        td.width = "100%";
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        td = document.createElement("TD");
        td.id = this.getRightSliderId();
        td.onmousedown = new Function("return false;");
        td.style.cursor="e-resize";
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);
    }

    this.dragDiv.style.top = 0;
    this.dragDiv.style.left = left + 'px';
    this.dragDiv.style.width = right - left + 'px';
    this.dragDiv.style.height = '100%';
    this.dragDiv.style.display = "block";
};

nlSchedulerRenderer.prototype.hideDraggedTimeSlots = function()
{
    if (this.dragDiv)
    {
        this.dragDiv.style.display = "none";
    }
};

/**
 * highlight or de-highlight item timeslot cells
 * @param dayIdx day index
 * @param startTimeSlotIdx the starting index of the time slots
 * @param endTimeSlotIdx the end index of the time slots
 * @param bHighLight highlight or not
 */
nlSchedulerRenderer.prototype.highLightItemsTimeSlotCells = function (dayIdx, startTimeSlotIdx, endTimeSlotIdx, bHighLight)
{
    for (var i=startTimeSlotIdx; i<=endTimeSlotIdx; i++)
    {
        for (var key in this.owner.selectedItems)
        {
            if (this.owner.getSelectedItem(key) != null)
            {
                var cell = document.getElementById(this.getItemTimeSlotCellId(this.owner.selectedItems[key].id, dayIdx, i));
	            cell.dataset.state = bHighLight ? SLOT_SELECTED : SLOT_AVAILABLE;
            }
        }
    }
};

nlSchedulerRenderer.prototype.resize = function()
{
    //adjust the width of each cell;
    for (var key in this.items)
    {
        var item = this.items[key];
        if (item == null)
            continue;
        for (var i=0; i<this.owner.numDays; i++)
        {
            for (var j=0; j<this.owner.numTimeSlots; j++)
            {
                var hearderColumn = document.getElementById(this.getTimeSlotHearderCellId(i,j));
                var td = document.getElementById(this.getItemTimeSlotCellId(item.id, i, j));
                td.width = hearderColumn.offsetWidth-2;
            }
        }
    }
    //redraw the drag div
    if (this.dragDiv != "undefined" && this.dragDiv != null && this.dragDiv.style.visibility == "visible")
        this.showDraggedTimeSlots();
 };

/**
 *
 */

nlSchedulerRenderer.prototype.updateScheduleEventButton = function()
{
    var enabled = false;
    if (this.owner.getSizeOfSelectedItems() > 0 && this.owner.selectedStartTime != null && this.owner.selectedEndTime != null)
        enabled = true;
    var buttonElem = document.getElementById(this.getControlId(SCHEDULE_EVENT_BUTTON_NAME));
    if (buttonElem)
        buttonElem.disabled = !enabled;
};

function esShowToolTip (id, content)
{
    if (NS.form.isInited() && window['scheduler' + id].mouseDown != true /*not dragging*/)
          showToolTip(content, "");
}

function esHideToolTip ()
{
    if (NS.form.isInited())
          hideToolTip();
}


nlSchedulerRenderer.prototype.getItemTimeSlotCellId = function (itemId, dayIdx, timeIdx)
{
    return "item_ts_" + this.owner.id + "_" + itemId + "_" + dayIdx + "_" + timeIdx;
};

nlSchedulerRenderer.prototype.getControlId = function (controlName)
{
    return controlName + "_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getDatePickContainerId = function ()
{
    return "date_pick_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getDateControlId = function ()
{
    if (this.calendarFieldId != null)
        return this.calendarFieldId;

    return "datefield_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getBusyIndicatorId = function ()
{
    return "busy_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getDragDivId = function ()
{
    return "dragdiv_" + this.owner.id;
};



/*
 * Generate the left slider Id
 */
nlSchedulerRenderer.prototype.getLeftSliderId = function ()
{
    return "slider_l_" + this.owner.id;
};

/*
 * Generate the right slider Id
 */
nlSchedulerRenderer.prototype.getRightSliderId = function ()
{
    return "slider_r_" + this.owner.id;
};

/*
 * Generate the id string for item checkbox
 * @param id the id of the item
 */
nlSchedulerRenderer.prototype.getItemSelectCheckBoxId = function (id)
{
    return "item_check_" + this.owner.id + "_" + id;
};

/*
 * Generate the id string for item checkbox
 */
nlSchedulerRenderer.prototype.getSelectAllCheckBoxId = function ()
{
    return "check_" + this.owner.id;
};

/*
 * Generate the id string for item table row element
 * @param id the id of the item
 */
nlSchedulerRenderer.prototype.getItemRowId = function (id)
{
    return "item_row_" + this.owner.id + "_" + id;
};

nlSchedulerRenderer.prototype.getRowContainerId = function ()
{
    return "item_rows_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getTableId = function ()
{
    return "tb_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getTimeSlotHearderRowId = function()
{
    return "tsh_" + this.owner.id;
};


nlSchedulerRenderer.prototype.getTimeSlotHeaderDivId = function()
{
    return "tsh_div_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getTimeSlotHearderCellId = function (dayIdx, timeSlotIdx)
{
    return "tsh_" + this.owner.id + "_" + dayIdx + "_" + timeSlotIdx;
};

nlSchedulerRenderer.prototype.getCommonAvailabilityDivId = function()
{
    return  "ca_div_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getCommonAvailabilityRowId = function()
{
    return  "ca_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getCommonAvailabilityCellId = function (dayIdx, timeSlotIdx)
{
    return this.getCommonAvailabilityDivId() + "_" + dayIdx + "_" + timeSlotIdx;
};

nlSchedulerRenderer.prototype.getDateLabelId = function()
{
    return  "date_" + this.owner.id;
};

nlSchedulerRenderer.prototype.getTimeLabelId = function()
{
    return  "time_" + this.owner.id;
};



nlSchedulerRenderer.prototype.getTimeString = function (time, b24h, bShowAmpm)
{
    var hour = Math.floor(time/60);
    var min = time % 60;

    var suffix = "";
    if (!b24h)
    {
        if (hour <12)
        {
            if (hour==0)
                hour = 12;
            suffix = "am";
        }
        else
        {
            if (hour > 12)
                hour -= 12;
            suffix = "pm";
        }
    }

    if (hour<=9)
        hour = "&nbsp;" + hour;
    if (min<=9)
        min = "0" + min;


    return hour + ":" + min + ((!b24h && bShowAmpm) ? suffix : "");
};






function nlTable (id, containerElemId, numFixedColumns, numFixedRows, defaultHeight, defaultWidth)
{
    this.id = id + "_nlt";
    window[this.id] = this;
    this.containerElem = document.getElementById(containerElemId);

    this.tableElemId = "table_" + id;
    this.fixedColumnsBlockId = "fixed_r_" + id;
    this.scrollingHeaderBlockId = "fixed_h_" + id;
    this.fixedColumnsHeaderBlockId = "fixed_ch_" + id;
    this.scrollingColumnsBlockId = "scroll_" + id;
    this.scrollingColumnsInnerDivBlockId = "scroll_innerDiv_" + id;
    this.fixedColumnsTableId = "fixed_rt_" + id;
    this.scrollingColumnsTableId = "scroll_rt_" + id;

    if( numFixedColumns !== null && numFixedColumns != "undefined" )
        this.numFixedColumns = numFixedColumns;
    else
        this.numFixedColumns = 0;

    if( numFixedRows !== null && numFixedRows != "undefined" )
        this.numFixedRows = numFixedRows;
    else
        this.numFixedRows = 0;

    if( typeof defaultHeight != "undefined" && defaultHeight !== null )
        this.defaultHeight = defaultHeight;
    else
        this.defaultHeight = 20;


    if( typeof defaultWidth != "undefined" && defaultWidth !== null)
        this.defaultWidth = defaultWidth;
    else
        this.defaultWidth = 40;


    this.init();
}


nlTable.prototype.init = function ()
{
    this.numRows = 0;

    this.rows = {};
    this.orderedRows = [];

};

nlTable.prototype.addScrollEventHandlers = function (scrollingColumnsDiv)
{
    var id = this.id;
    attachEventHandler("scroll", scrollingColumnsDiv, function(evnt){
        if (window[id]) window[id].handleScroll(evnt);
    });
};

nlTable.prototype.handleScroll = function (evnt)
{
    var elem = getEventTarget(evnt);
    if (elem == null || elem.id != this.scrollingColumnsBlockId)
        return;
    var fixedColumnsDiv = document.getElementById(this.fixedColumnsBlockId);
    if (fixedColumnsDiv != null)
        fixedColumnsDiv.scrollTop = elem.scrollTop;
};


nlTable.prototype.setFixedColumnsBlockWidth = function()
{

};

nlTable.prototype.setColumnWidths = function(defaultWidth, defaultHeight)
{
    this.defaultWidth = defaultWidth;
    this.defaultHeight = defaultHeight;
    this.columnWidths = widths;
    this.columnHeights = heights;
};

nlTable.prototype.setNumFixedColumns = function (num)
{
    this.numFixedColumns = num;
};

nlTable.prototype.setNumFixedRows = function (num)
{
    this.numFixedRows = num;
};

nlTable.prototype.setCellContent = function (row, column, content)
{
};

/**
 *  get the html element of the table cell
 */
nlTable.prototype.getCell = function (rowId, cellId)
{
    var row = this.rows[rowId];
    if (row == null)
        return null;
    return row.getCell(cellId);
};


nlTable.prototype.showInitLayout = function ()
{
    var tableElem = document.getElementById(this.tableElemId);
    if (tableElem != null)
        this.containerElem.removeChild(tableElem);

    var tableHtml = new Array();
    tableHtml[tableHtml.length] = "<table id='" + this.tableElemId + "' heght=100% width=100% cellspacing=0 cellpadding=0>";
    tableHtml[tableHtml.length] = "<tr>";
    tableHtml[tableHtml.length] = "<td id='" + this.fixedColumnsHeaderBlockId + "'></td>";
    tableHtml[tableHtml.length] = "<td width='100%'> <div id='" + this.scrollingHeaderBlockId + "'/> </td>";
    tableHtml[tableHtml.length] = "</tr>";
    tableHtml[tableHtml.length] = "<tr>";
    tableHtml[tableHtml.length] = "<td><div id='" + this.fixedColumnsBlockId + "'>";
    tableHtml[tableHtml.length] = "<table id='" + this.fixedColumnsTableId + "' width=100% cellpadding=0 cellspacing=0><tbody></tbody></table>";
    tableHtml[tableHtml.length] = "</div></td>";
    tableHtml[tableHtml.length] = "<td cellspacing=0 cellpadding=0><div id='" + this.scrollingColumnsBlockId + "'>";
    tableHtml[tableHtml.length] = "<div id='" + this.scrollingColumnsInnerDivBlockId + "'>";
    tableHtml[tableHtml.length] = "<table id='" + this.scrollingColumnsTableId + "' cellpadding=0 cellspacing=0><tbody></tbody></table>";
    tableHtml[tableHtml.length] = "</div>";
    tableHtml[tableHtml.length] = "</div></td>";
    tableHtml[tableHtml.length] = "</tr>";
    tableHtml[tableHtml.length] = "</table>";

    this.containerElem.innerHTML = tableHtml.join("");

    this.fixedColumnsTable = document.getElementById(this.fixedColumnsTableId);

    this.scrollingColumnsTable = document.getElementById(this.scrollingColumnsTableId);

    var scrollingColumnsDiv = document.getElementById(this.scrollingColumnsBlockId);
    this.addScrollEventHandlers(scrollingColumnsDiv);
};


nlTable.prototype.addRow = function (rowId, height, pos)
{
    var row = new nlRow(rowId, this);

    this.fixedColumnsTable = document.getElementById(this.fixedColumnsTableId);

    this.scrollingColumnsTable = document.getElementById(this.scrollingColumnsTableId);

    var rowHeight = null;
    if (typeof height == "undefined" || height == null)
        rowHeight = this.defaultHeight;
    else if (height != null)
        rowHeight = height;
    this.rows[rowId] = row;

    var nextRow = null;
    if (typeof pos == "undefined" || pos == null || pos >= this.orderedRows.length)
        this.orderedRows[this.orderedRows.length] = row;
    else
    {
        nextRow = this.orderedRows[pos];
        this.orderedRows.splice(pos, 0, row);
    }

    var fixedRowHeight= rowHeight + 2;

    row.addRowLayout(this.fixedColumnsTable, this.scrollingColumnsTable, fixedRowHeight, rowHeight, nextRow);
    return row;
};

nlTable.prototype.removeRow = function (rowId)
{
    var row = this.rows[rowId];
    if (row == null)
        return;

    row.removeRowLayout(this.fixedColumnsTable, this.scrollingColumnsTable);
    for (var i=0; i<this.orderedRows.length; i++)
    {
        if (this.orderedRows[i] == this.rows[rowId])
        {
            this.orderedRows.splice(i, 1);
            break;
        }
    }
    this.rows[rowId] = null;
    return;
};

nlTable.prototype.getRow = function (rowId)
{
    return this.rows[rowId];
};

nlTable.prototype.clearRows = function ()
{
    var div= document.getElementById(this.fixedColumnsBlockId);
    div.innerHTML = "<table id='" + this.fixedColumnsTableId + "' width=100% cellpadding=0 cellspacing=0><tbody></tbody></table>";

    div = document.getElementById(this.scrollingColumnsInnerDivBlockId);
    div.innerHTML = "<table id='" + this.scrollingColumnsTableId + "' cellpadding=0 cellspacing=0><tbody></tbody></table>";

    this.init();
};


nlTable.prototype.getFixedColumnsHeaderElem = function ()
{
    return document.getElementById(this.fixedColumnsHeaderBlockId);
};

nlTable.prototype.getScrollingHeaderElem = function ()
{
    return document.getElementById(this.scrollingHeaderBlockId);
};

function nlRow (id, table)
{
    this.id = id;
    this.table = table;
    this.fixedColumnsRowId = id + "_f";
    this.scrollingColumnsRowId = id + "_s";
}

nlRow.prototype.addRowLayout = function (fixedColumnsTable, scrollingColumnsTable, fixedRowHeight, height, nextRow)
{
    // add a row for the fixed columns
    var row = document.createElement("TR");
    row.id = this.fixedColumnsRowId;
    row.style.height = fixedRowHeight + 'px';
    if (nextRow == null)
        fixedColumnsTable.getElementsByTagName("TBODY")[0].appendChild(row);
    else
        fixedColumnsTable.getElementsByTagName("TBODY")[0].insertBefore(row, nextRow.fixedColumnsRow);
    this.fixedColumnsRow = row;

    // add a row for the scrolling columns
    row  = document.createElement("TR");
    row.id = this.scrollingColumnsRowId;
    row.style.height = height + 'px';
    if (nextRow == null)
        scrollingColumnsTable.getElementsByTagName("TBODY")[0].appendChild(row);
    else
        scrollingColumnsTable.getElementsByTagName("TBODY")[0].insertBefore(row, nextRow.scrollingColumnsRow);

    this.scrollingColumnsRow = row;
};

nlRow.prototype.removeRowLayout = function (fixedColumnsTable, scrollingColumnsTable)
{
    // remove this row for the fixed columns
    fixedColumnsTable.firstChild.removeChild(this.fixedColumnsRow);
    this.fixedColumnsRow = null;

    // remove this row for the scrolling columns
    scrollingColumnsTable.firstChild.removeChild(this.scrollingColumnsRow);
    this.scrollingColumnsRow = null;
};

nlRow.prototype.setHeight = function (height)
{
    this.fixedColumnsRow.height = height;
    this.scrollingColumnsRow.height = height;
};

nlRow.prototype.addCell = function(colIdx, id, content, className)
{
    var row = colIdx < this.table.numFixedColumns?this.fixedColumnsRow:this.scrollingColumnsRow;
    var td = document.createElement("TD");
    td.id = id;

	if (className) {
		td.className = className;
    }

    row.appendChild(td);

    td.innerHTML = content;

    return td;
};
