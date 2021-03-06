import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.mobilecomponents 0.2 as MobileComponents

Item {
	ColumnLayout {
		id: startpage
		anchors.fill: parent
		anchors.margins: MobileComponents.Units.gridUnit / 2

		property int buttonWidth: welcomeText.width * 0.66

		MobileComponents.Heading {
			Layout.bottomMargin: MobileComponents.Units.largeSpacing
			text: "Subsurface Divelog"
		}

		MobileComponents.Label {
			id: welcomeText
			Layout.fillWidth: true
			Layout.bottomMargin: MobileComponents.Units.largeSpacing
			text: manager.startPageText
			wrapMode: Text.WordWrap
			Layout.columnSpan: 2
		}
		Button {
			id: cloudstorageButton
			Layout.bottomMargin: MobileComponents.Units.largeSpacing
			Layout.preferredWidth: startpage.buttonWidth
			text: "Connect to CloudStorage..."
			onClicked: {
				stackView.push(cloudCredWindow)
			}
		}
		Button {
			id: computerButton
			Layout.preferredWidth: startpage.buttonWidth
			Layout.bottomMargin: MobileComponents.Units.largeSpacing
			text: "Transfer from dive computer..."
			onClicked: {
				stackView.push(downloadDivesWindow)
			}
		}
		Button {
			id: manualButton
			Layout.preferredWidth: startpage.buttonWidth
			Layout.bottomMargin: MobileComponents.Units.largeSpacing
			text: "Add dive manually..."
			onClicked: {
				manager.addDive();
				stackView.push(detailsWindow)
			}
		}
		Item {
			width: parent.width
			Layout.fillHeight: true
		}
	}
}
