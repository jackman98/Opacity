import QtQuick 2.10
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    Rectangle {
        id: mainW
        anchors.fill: parent
        color: "black"

        MyBlend {
            anchors.fill: r1
            source: r2
            foregroundSource: r1
            mode: "exclusion"
        }
//        Rectangle {
//            id: mask
//            anchors.right: r1.right
//            anchors.left: r2.left
//            anchors.top: r1.top
//            anchors.bottom: r1.bottom
//            color: "white"
//        }
        Rectangle {
            id: r1
            width: 100
            height: width
            color: "red"
            opacity: 0.5
        }

        Rectangle {
            id: r2
            x: 50
            width: 100
            height: width
            color: "red"
            opacity: 0.5
        }


    }
}
