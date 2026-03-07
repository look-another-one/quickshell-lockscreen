import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

	color: "black"
	
	property bool showPassword: false

	// Handle key presses to trigger password screen or dismiss it
	focus: true
	Keys.onPressed: (event) => {
		if (!showPassword) {
			showPassword = true;
			passwordBox.forceActiveFocus();
			event.accepted = true;
		} else if (event.key === Qt.Key_Escape) {
			showPassword = false;
			root.forceActiveFocus();
			root.context.currentText = "";
			event.accepted = true;
		}
	}

	Image {
		id: bgImg
		source: "dark_jungle.jpg"
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
	}

	MultiEffect {
		id: bgEffect
		anchors.fill: parent
		source: bgImg
		blurEnabled: true
		blurMax: 64
		blur: 0.8
		opacity: root.showPassword ? 0.0 : 1.0
		Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
	}

	Rectangle {
		anchors.fill: parent
		color: "black"
		opacity: root.showPassword ? 0.3 : 0.5
		Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
	}

	ColumnLayout {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: 120
		}
		spacing: 10

		Label {
			id: clock
			property var date: new Date()
			
			Layout.alignment: Qt.AlignHCenter
			renderType: Text.NativeRendering
			font.family: "Impact" // Block-like font
			font.pointSize: 96
			font.weight: Font.Black
			color: "white"

			Timer {
				running: true
				repeat: true
				interval: 1000
				onTriggered: clock.date = new Date();
			}

			text: {
				const hours = this.date.getHours().toString().padStart(2, '0');
				const minutes = this.date.getMinutes().toString().padStart(2, '0');
				const seconds = this.date.getSeconds().toString().padStart(2, '0');
				return `${hours}:${minutes}:${seconds}`;
			}
		}
		
		Label {
			Layout.alignment: Qt.AlignHCenter
			renderType: Text.NativeRendering
			font.pointSize: 24
			font.weight: Font.Light
			color: "#E0E0E0"
			text: clock.date.toLocaleDateString(Qt.locale(), Locale.LongFormat)
		}
	}

	Label {
		text: "Press any key to unlock"
		anchors {
			bottom: parent.bottom
			bottomMargin: 140
			horizontalCenter: parent.horizontalCenter
		}
		color: "#FFFFFF"
		font.pointSize: 16
		font.weight: Font.Light
		opacity: root.showPassword ? 0 : 0.8
		Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutQuad } }
		
		SequentialAnimation on opacity {
			running: !root.showPassword
			loops: Animation.Infinite
			NumberAnimation { to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
			NumberAnimation { to: 0.8; duration: 2000; easing.type: Easing.InOutSine }
		}
	}

	Item {
		id: passwordContainer
		width: 400
		height: 200
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: root.showPassword ? parent.height * 0.25 : -300
		}
		opacity: root.showPassword ? 1 : 0
		Behavior on anchors.bottomMargin { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
		Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }

		SequentialAnimation {
			id: shakeAnim
			NumberAnimation { target: passwordContainer; property: "anchors.horizontalCenterOffset"; to: 15; duration: 50 }
			NumberAnimation { target: passwordContainer; property: "anchors.horizontalCenterOffset"; to: -15; duration: 50 }
			NumberAnimation { target: passwordContainer; property: "anchors.horizontalCenterOffset"; to: 10; duration: 50 }
			NumberAnimation { target: passwordContainer; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50 }
			NumberAnimation { target: passwordContainer; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
		}

		Connections {
			target: root.context
			function onShowFailureChanged() {
				if (root.context.showFailure) shakeAnim.start();
			}
		}

		ColumnLayout {
			anchors.centerIn: parent
			spacing: 20

			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				// Heuristic: If we type an uppercase letter while Shift is NOT pressed, Caps Lock must be ON.
				property bool isCapsActive: passwordBox.text.length > 0 && 
											/[A-Z]/.test(passwordBox.text.charAt(passwordBox.text.length - 1)) && 
											!passwordBox.shiftDown

				visible: isCapsActive
				opacity: visible ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 300 } }
				
				Rectangle {
					width: 24; height: 24; radius: 12; color: "#FF9800"
					Label { anchors.centerIn: parent; text: "!"; color: "black"; font.bold: true }
				}
				Label {
					text: "Caps Lock is On"
					color: "#FF9800"
					font.pointSize: 12
				}
			}

			Rectangle {
				id: inputBg
				Layout.preferredWidth: Math.max(250, 40 + passwordBox.text.length * 40)
				Layout.preferredHeight: 60
				Layout.alignment: Qt.AlignHCenter
				radius: 30
				color: passwordBox.activeFocus ? "#30FFFFFF" : "#15FFFFFF"
				border.color: passwordBox.activeFocus ? "#80FFFFFF" : "#30FFFFFF"
				border.width: root.context.showFailure ? 2 : 1
				
				Rectangle {
					anchors.fill: parent
					radius: parent.radius
					color: "transparent"
					border.color: "#FF5252"
					border.width: 2
					opacity: root.context.showFailure ? 1 : 0
					Behavior on opacity { NumberAnimation { duration: 300 } }
				}

				Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
				Behavior on color { ColorAnimation { duration: 300 } }
				Behavior on border.color { ColorAnimation { duration: 300 } }

				TextInput {
					id: passwordBox
					anchors.fill: parent
					anchors.margins: 10
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					color: "white"
					font.pointSize: 24
					echoMode: TextInput.Password
					passwordCharacter: "●"
					selectionColor: "#80FFFFFF"
					enabled: !root.context.unlockInProgress
					inputMethodHints: Qt.ImhSensitiveData

					property bool shiftDown: false
					Keys.onPressed: (event) => {
						if (event.key === Qt.Key_Shift) shiftDown = true;
					}
					Keys.onReleased: (event) => {
						if (event.key === Qt.Key_Shift) shiftDown = false;
					}

					Rectangle {
						anchors.centerIn: parent
						width: parent.width + 10
						height: parent.height + 10
						radius: 35
						color: "transparent"
						border.color: "white"
						border.width: 1
						opacity: parent.activeFocus ? 0.3 : 0
						scale: parent.activeFocus ? 1.0 : 0.95
						Behavior on opacity { NumberAnimation { duration: 400 } }
						Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
					}

					onTextChanged: root.context.currentText = this.text;
					onAccepted: root.context.tryUnlock();

					Connections {
						target: root.context
						function onCurrentTextChanged() {
							if (passwordBox.text !== root.context.currentText) {
								passwordBox.text = root.context.currentText;
							}
						}
					}
				}
			}

			Item {
				Layout.preferredWidth: 30
				Layout.preferredHeight: 30
				Layout.alignment: Qt.AlignHCenter
				opacity: root.context.unlockInProgress ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 200 } }
				
				Rectangle {
					anchors.centerIn: parent
					width: 20; height: 20
					radius: 10
					border.color: "white"
					border.width: 2
					color: "transparent"
					
					RotationAnimation on rotation {
						loops: Animation.Infinite
						from: 0; to: 360; duration: 800
						running: root.context.unlockInProgress
					}
					
					Rectangle {
						width: 10; height: 10
						radius: 5; color: "white"
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
					}
				}
			}
		}
	}

	RowLayout {
		anchors {
			bottom: parent.bottom
			right: parent.right
			margins: 40
		}
		spacing: 20

		component PowerButton: Rectangle {
			id: pBtn
			property string iconText: "?"
			property string tooltip: ""
			signal click()
			
			width: 50; height: 50
			radius: 25
			color: ma.containsMouse ? "#40FFFFFF" : "#1AFFFFFF"
			border.color: ma.containsMouse ? "#80FFFFFF" : "#30FFFFFF"
			border.width: 1

			Behavior on color { ColorAnimation { duration: 200 } }
			Behavior on border.color { ColorAnimation { duration: 200 } }
			Behavior on scale { NumberAnimation { duration: 150 } }
			
			scale: ma.pressed ? 0.9 : (ma.containsMouse ? 1.1 : 1.0)

			Label {
				anchors.centerIn: parent
				text: pBtn.iconText
				color: "white"
				font.pointSize: 18
			}

			MouseArea {
				id: ma
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: pBtn.click()
			}

			Rectangle {
				width: tooltipLabel.width + 20
				height: tooltipLabel.height + 14
				anchors.bottom: pBtn.top
				anchors.bottomMargin: 10
				anchors.horizontalCenter: pBtn.horizontalCenter
				color: "#A0000000"
				radius: 8
				opacity: ma.containsMouse ? 1 : 0
				visible: opacity > 0
				Behavior on opacity { NumberAnimation { duration: 200 } }

				Label {
					id: tooltipLabel
					anchors.centerIn: parent
					text: pBtn.tooltip
					color: "white"
					font.pointSize: 11
				}
			}
		}

		PowerButton { iconText: "⏻"; tooltip: "Shutdown"; onClick: root.context.shutdown() }
		PowerButton { iconText: "❄"; tooltip: "Hibernate"; onClick: root.context.hibernate() }
		PowerButton { iconText: "☾"; tooltip: "Sleep"; onClick: root.context.sleep() }
		PowerButton { iconText: "↻"; tooltip: "Restart"; onClick: root.context.restart() }
		PowerButton { iconText: "➜"; tooltip: "Logout"; onClick: root.context.logout() }
	}
}
