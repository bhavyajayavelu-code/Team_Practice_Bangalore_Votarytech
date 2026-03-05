/****************************************************************************
** Meta object code from reading C++ file 'wifimanager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../backend/wifimanager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'wifimanager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_WifiManager_t {
    QByteArrayData data[24];
    char stringdata0[320];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_WifiManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_WifiManager_t qt_meta_stringdata_WifiManager = {
    {
QT_MOC_LITERAL(0, 0, 11), // "WifiManager"
QT_MOC_LITERAL(1, 12, 15), // "networksChanged"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 17), // "connectionChanged"
QT_MOC_LITERAL(4, 47, 15), // "scanningChanged"
QT_MOC_LITERAL(5, 63, 13), // "scanCompleted"
QT_MOC_LITERAL(6, 77, 17), // "connectionSuccess"
QT_MOC_LITERAL(7, 95, 16), // "connectionFailed"
QT_MOC_LITERAL(8, 112, 5), // "error"
QT_MOC_LITERAL(9, 118, 16), // "passwordRequired"
QT_MOC_LITERAL(10, 135, 4), // "ssid"
QT_MOC_LITERAL(11, 140, 14), // "onScanFinished"
QT_MOC_LITERAL(12, 155, 8), // "exitCode"
QT_MOC_LITERAL(13, 164, 17), // "onConnectFinished"
QT_MOC_LITERAL(14, 182, 12), // "scanNetworks"
QT_MOC_LITERAL(15, 195, 16), // "connectToNetwork"
QT_MOC_LITERAL(16, 212, 8), // "password"
QT_MOC_LITERAL(17, 221, 21), // "disconnectFromNetwork"
QT_MOC_LITERAL(18, 243, 13), // "forgetNetwork"
QT_MOC_LITERAL(19, 257, 18), // "getNetworkStrength"
QT_MOC_LITERAL(20, 276, 8), // "networks"
QT_MOC_LITERAL(21, 285, 11), // "currentSSID"
QT_MOC_LITERAL(22, 297, 11), // "isConnected"
QT_MOC_LITERAL(23, 309, 10) // "isScanning"

    },
    "WifiManager\0networksChanged\0\0"
    "connectionChanged\0scanningChanged\0"
    "scanCompleted\0connectionSuccess\0"
    "connectionFailed\0error\0passwordRequired\0"
    "ssid\0onScanFinished\0exitCode\0"
    "onConnectFinished\0scanNetworks\0"
    "connectToNetwork\0password\0"
    "disconnectFromNetwork\0forgetNetwork\0"
    "getNetworkStrength\0networks\0currentSSID\0"
    "isConnected\0isScanning"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_WifiManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      14,   14, // methods
       4,  114, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       7,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   84,    2, 0x06 /* Public */,
       3,    0,   85,    2, 0x06 /* Public */,
       4,    0,   86,    2, 0x06 /* Public */,
       5,    0,   87,    2, 0x06 /* Public */,
       6,    0,   88,    2, 0x06 /* Public */,
       7,    1,   89,    2, 0x06 /* Public */,
       9,    1,   92,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      11,    1,   95,    2, 0x08 /* Private */,
      13,    1,   98,    2, 0x08 /* Private */,

 // methods: name, argc, parameters, tag, flags
      14,    0,  101,    2, 0x02 /* Public */,
      15,    2,  102,    2, 0x02 /* Public */,
      17,    0,  107,    2, 0x02 /* Public */,
      18,    1,  108,    2, 0x02 /* Public */,
      19,    1,  111,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    8,
    QMetaType::Void, QMetaType::QString,   10,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,   12,
    QMetaType::Void, QMetaType::Int,   12,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,   10,   16,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   10,
    QMetaType::QString, QMetaType::QString,   10,

 // properties: name, type, flags
      20, QMetaType::QStringList, 0x00495001,
      21, QMetaType::QString, 0x00495001,
      22, QMetaType::Bool, 0x00495001,
      23, QMetaType::Bool, 0x00495001,

 // properties: notify_signal_id
       0,
       1,
       1,
       2,

       0        // eod
};

void WifiManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<WifiManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->networksChanged(); break;
        case 1: _t->connectionChanged(); break;
        case 2: _t->scanningChanged(); break;
        case 3: _t->scanCompleted(); break;
        case 4: _t->connectionSuccess(); break;
        case 5: _t->connectionFailed((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 6: _t->passwordRequired((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 7: _t->onScanFinished((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 8: _t->onConnectFinished((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 9: _t->scanNetworks(); break;
        case 10: _t->connectToNetwork((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 11: _t->disconnectFromNetwork(); break;
        case 12: _t->forgetNetwork((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 13: { QString _r = _t->getNetworkStrength((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (WifiManager::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::networksChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::connectionChanged)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::scanningChanged)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::scanCompleted)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::connectionSuccess)) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::connectionFailed)) {
                *result = 5;
                return;
            }
        }
        {
            using _t = void (WifiManager::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&WifiManager::passwordRequired)) {
                *result = 6;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<WifiManager *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QStringList*>(_v) = _t->networks(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->currentSSID(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->isConnected(); break;
        case 3: *reinterpret_cast< bool*>(_v) = _t->isScanning(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject WifiManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_WifiManager.data,
    qt_meta_data_WifiManager,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *WifiManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WifiManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_WifiManager.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WifiManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 14)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 14)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 14;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 4;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 4;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 4;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 4;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 4;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void WifiManager::networksChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void WifiManager::connectionChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void WifiManager::scanningChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void WifiManager::scanCompleted()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void WifiManager::connectionSuccess()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void WifiManager::connectionFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void WifiManager::passwordRequired(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
