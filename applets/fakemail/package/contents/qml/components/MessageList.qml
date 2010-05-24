import Qt 4.7
import Qt.widgets 4.7
import Plasma 0.1 as Plasma

Item {
    id: main
    signal itemClicked
    signal newClicked

    ListModel {
        id: messagesModel
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "Foo Bar"
            subject: "[PATCH] Crash fix"
            text : "Hello,<br/> this patch will fix the problem you encounered"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
        ListElement {
            from: "John Doe"
            subject: "Hello"
            text : "Hello, how are you?"
        }
    }

    Component {
        id : messageDelegate
        Item {
            width: list.width
            height: layout.height

            Rectangle {
                id : background
                anchors.fill : parent

                Column {
                    id : layout

                    Text {
                        text: subject
                    }
                    Text {
                        text: from
                    }
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.15)  }
                }
            }
            MouseArea {
                id: itemMouse
                anchors.fill: parent
                onClicked: {
                    list.currentIndex = index
                    main.itemClicked()
                }
            }
        }
    }


    Plasma.Frame {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        frameShadow : "Raised"

        layout : QGraphicsLinearLayout {
            Plasma.PushButton {
                //FIXME: either icons should be accessible by name or bindings for KIcon would be neede
                //icon: "mail-message-new"
                text: "Write"
                onClicked : main.newClicked()
            }
            Plasma.PushButton {
                //icon: "mail-receive"
                text: "Check"
            }
 
            QGraphicsWidget{}

            Plasma.LineEdit {
                clickMessage: "Search..."
                clearButtonShown: true
            }
        }
    }

    ListView {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: frame.bottom
        clip: true
        model: messagesModel
        delegate: messageDelegate
    }
    
}