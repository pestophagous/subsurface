#include "diveeventitem.h"
#include "diveplotdatamodel.h"
#include "divecartesianaxis.h"
#include "animationfunctions.h"
#include "libdivecomputer.h"
#include "profile.h"
#include "gettextfromc.h"
#include "metrics.h"

#include "util-assert.h"

extern struct ev_select *ev_namelist;
extern int evn_used;

DiveEventItem::DiveEventItem(QObject *parent) : DivePixmapItem(parent),
	vAxis(NULL),
	hAxis(NULL),
	dataModel(NULL),
	internalEvent(NULL),
	check_duration(),
	check_type(0),
	check_flags(0),
	check_value(0),
	check_deleted(false),
	check_namelen(0)
{
	setFlag(ItemIgnoresTransformations);
}


void DiveEventItem::setHorizontalAxis(DiveCartesianAxis *axis)
{
	hAxis = axis;
	recalculatePos(true);
}

void DiveEventItem::setModel(DivePlotDataModel *model)
{
	dataModel = model;
	recalculatePos(true);
}

void DiveEventItem::setVerticalAxis(DiveCartesianAxis *axis)
{
	vAxis = axis;
	recalculatePos(true);
	connect(vAxis, SIGNAL(sizeChanged()), this, SLOT(recalculatePos()));
}

struct event *DiveEventItem::getEvent()
{
	return internalEvent;
}

void DiveEventItem::setEvent(struct event *ev)
{
	if (!ev)
		return;
	internalEvent = ev;
	check_duration = internalEvent->time;
	check_type = internalEvent->type;
	check_flags = internalEvent->flags;
	check_value = internalEvent->value;
	check_deleted = internalEvent->deleted;
	check_namelen = strlen(internalEvent->name);

	setupPixmap();
	setupToolTipString();
	recalculatePos(true);
}

void DiveEventItem::setupPixmap()
{
	const IconMetrics& metrics = defaultIconMetrics();
	int sz_bigger = metrics.sz_med + metrics.sz_small; // ex 40px
	int sz_pix = sz_bigger/2; // ex 20px

#define EVENT_PIXMAP(PIX) QPixmap(QString(PIX)).scaled(sz_pix, sz_pix, Qt::KeepAspectRatio, Qt::SmoothTransformation)
#define EVENT_PIXMAP_BIGGER(PIX) QPixmap(QString(PIX)).scaled(sz_bigger, sz_bigger, Qt::KeepAspectRatio, Qt::SmoothTransformation)
	if (same_string(internalEvent->name, "")) {
		setPixmap(EVENT_PIXMAP(":warning"));
	} else if (internalEvent->type == SAMPLE_EVENT_BOOKMARK) {
		setPixmap(EVENT_PIXMAP(":flag"));
	} else if (strcmp(internalEvent->name, "heading") == 0 ||
		   (same_string(internalEvent->name, "SP change") && internalEvent->time.seconds == 0)) {
		// 2 cases:
		// a) some dive computers have heading in every sample
		// b) at t=0 we might have an "SP change" to indicate dive type
		// in both cases we want to get the right data into the tooltip but don't want the visual clutter
		// so set an "almost invisible" pixmap (a narrow but somewhat tall, basically transparent pixmap)
		// that allows tooltips to work when we don't want to show a specific
		// pixmap for an event, but want to show the event value in the tooltip
		QPixmap transparentPixmap(4, 20);
		transparentPixmap.fill(QColor::fromRgbF(1.0, 1.0, 1.0, 0.01));
		setPixmap(transparentPixmap);
	} else if (event_is_gaschange(internalEvent)) {
		if (internalEvent->gas.mix.he.permille)
			setPixmap(EVENT_PIXMAP_BIGGER(":gaschangeTrimix"));
		else if (gasmix_is_air(&internalEvent->gas.mix))
			setPixmap(EVENT_PIXMAP_BIGGER(":gaschangeAir"));
		else
			setPixmap(EVENT_PIXMAP_BIGGER(":gaschangeNitrox"));
	} else {
		setPixmap(EVENT_PIXMAP(":warning"));
	}
#undef EVENT_PIXMAP
}

void DiveEventItem::setupToolTipString()
{
	// we display the event on screen - so translate
	QString name = gettextFromC::instance()->tr(internalEvent->name);
	int value = internalEvent->value;
	int type = internalEvent->type;
	if (value) {
		if (event_is_gaschange(internalEvent)) {
			name += ": ";
			name += gasname(&internalEvent->gas.mix);

			/* Do we have an explicit cylinder index?  Show it. */
			if (internalEvent->gas.index >= 0)
				name += QString(" (cyl %1)").arg(internalEvent->gas.index+1);
		} else if (type == SAMPLE_EVENT_PO2 && name == "SP change") {
			name += QString(":%1").arg((double)value / 1000);
		} else {
			name += QString(":%1").arg(value);
		}
	} else if (type == SAMPLE_EVENT_PO2 && name == "SP change") {
		// this is a bad idea - we are abusing an existing event type that is supposed to
		// warn of high or low pO₂ and are turning it into a set point change event
		name += "\n" + tr("Manual switch to OC");
	} else {
		name += internalEvent->flags == SAMPLE_FLAGS_BEGIN ? tr(" begin", "Starts with space!") :
								     internalEvent->flags == SAMPLE_FLAGS_END ? tr(" end", "Starts with space!") : "";
	}
	// qDebug() << name;
	setToolTip(name);
}

void DiveEventItem::eventVisibilityChanged(const QString &eventName, bool visible)
{
}

bool DiveEventItem::shouldBeHidden()
{
	struct event *event = internalEvent;

	/*
	 * Some gas change events are special. Some dive computers just tell us the initial gas this way.
	 * Don't bother showing those
	 */
	struct sample *first_sample = &get_dive_dc(&displayed_dive, dc_number)->sample[0];
	if (!strcmp(event->name, "gaschange") &&
	    (event->time.seconds == 0 ||
	     (first_sample && event->time.seconds == first_sample->time.seconds)))
		return true;

	for (int i = 0; i < evn_used; i++) {
		if (!strcmp(event->name, ev_namelist[i].ev_name) && ev_namelist[i].plot_ev == false)
			return true;
	}
	return false;
}

void DiveEventItem::recalculatePos(bool instant)
{
	if (!vAxis || !hAxis || !internalEvent || !dataModel)
		return;

	FASSERT( check_duration.seconds == internalEvent->time.seconds, "mangled duration" );
	FASSERT( check_type == internalEvent->type, "mangled type" );
	FASSERT( check_flags == internalEvent->flags, "mangled falgs" );
	FASSERT( check_value == internalEvent->value, "mangled value" );
	FASSERT( check_deleted == internalEvent->deleted, "mangled deleted" );
	FASSERT( check_namelen == strlen(internalEvent->name), "mangled name" );

	QModelIndexList result = dataModel->match(dataModel->index(0, DivePlotDataModel::TIME), Qt::DisplayRole, internalEvent->time.seconds);
	if (result.isEmpty()) {
		Q_ASSERT("can't find a spot in the dataModel");
		hide();
		return;
	}
	if (!isVisible() && !shouldBeHidden())
		show();
	int depth = dataModel->data(dataModel->index(result.first().row(), DivePlotDataModel::DEPTH)).toInt();
	qreal x = hAxis->posAtValue(internalEvent->time.seconds);
	qreal y = vAxis->posAtValue(depth);
	if (!instant)
		Animations::moveTo(this, x, y);
	else
		setPos(x, y);
	if (isVisible() && shouldBeHidden())
		hide();
}
