#ifndef DIVECOMPUTER_H
#define DIVECOMPUTER_H

#include <QString>
#include <QMap>
#include <stdint.h>

class DiveComputerNode {
public:
	DiveComputerNode(QString m, uint32_t d, QString s, QString f, QString n)
	    : model(m), deviceId(d), serialNumber(s), firmware(f), nickName(n) {};
	bool operator==(const DiveComputerNode &a) const;
	bool operator!=(const DiveComputerNode &a) const;
	bool changesValues(const DiveComputerNode &b) const;
	void showchanges(const QString &n, const QString &s, const QString &f) const;
	QString model;
	uint32_t deviceId;
	QString serialNumber;
	QString firmware;
	QString nickName;
};

class DiveComputerList {
public:
	DiveComputerList();
	~DiveComputerList();
	const DiveComputerNode *getExact(const QString &m, uint32_t d);
	const DiveComputerNode *get(const QString &m);
	void addDC(QString m, uint32_t d, QString n = QString(), QString s = QString(), QString f = QString());
	DiveComputerNode matchDC(const QString &m, uint32_t d);
	DiveComputerNode matchModel(const QString &m);
	QMultiMap<QString, DiveComputerNode> dcMap;
	QMultiMap<QString, DiveComputerNode> dcWorkingMap;
};

extern DiveComputerList dcList;

#endif
