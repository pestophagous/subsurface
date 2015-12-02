#ifndef DIVEEVENTITEM_H
#define DIVEEVENTITEM_H

#include "divepixmapitem.h"
#include "units.h"
class DiveCartesianAxis;
class DivePlotDataModel;
struct event;

class DiveEventItem : public DivePixmapItem {
	Q_OBJECT
public:
	DiveEventItem(QObject *parent = 0);
	void setEvent(struct event *ev);
	struct event *getEvent();
	void eventVisibilityChanged(const QString &eventName, bool visible);
	void setVerticalAxis(DiveCartesianAxis *axis);
	void setHorizontalAxis(DiveCartesianAxis *axis);
	void setModel(DivePlotDataModel *model);
	bool shouldBeHidden();
public
slots:
	void recalculatePos(bool instant = false);

private:
	void setupToolTipString();
	void setupPixmap();
	DiveCartesianAxis *vAxis;
	DiveCartesianAxis *hAxis;
	DivePlotDataModel *dataModel;
	struct event *internalEvent;

	duration_t check_duration;
	int check_type;
	int check_flags;
	int check_value;
	bool check_deleted;
	size_t check_namelen;
};

#endif // DIVEEVENTITEM_H
