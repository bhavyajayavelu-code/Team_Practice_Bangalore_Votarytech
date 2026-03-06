/****************************************************************************
** Meta object code from reading C++ file 'callmanager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../backend/callmanager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'callmanager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_CallManager_t {
    QByteArrayData data[27];
    char stringdata0[357];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_CallManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_CallManager_t qt_meta_stringdata_CallManager = {
    {
QT_MOC_LITERAL(0, 0, 11), // "CallManager"
QT_MOC_LITERAL(1, 12, 13), // "callInitiated"
QT_MOC_LITERAL(2, 26, 0), // ""
QT_MOC_LITERAL(3, 27, 6), // "number"
QT_MOC_LITERAL(4, 34, 10), // "callFailed"
QT_MOC_LITERAL(5, 45, 6), // "reason"
QT_MOC_LITERAL(6, 52, 7), // "smsSent"
QT_MOC_LITERAL(7, 60, 7), // "success"
QT_MOC_LITERAL(8, 68, 18), // "emergencyTriggered"
QT_MOC_LITERAL(9, 87, 8), // "location"
QT_MOC_LITERAL(10, 96, 15), // "locationUpdated"
QT_MOC_LITERAL(11, 112, 16), // "vehicleIdChanged"
QT_MOC_LITERAL(12, 129, 9), // "vehicleId"
QT_MOC_LITERAL(13, 139, 17), // "onPositionUpdated"
QT_MOC_LITERAL(14, 157, 16), // "QGeoPositionInfo"
QT_MOC_LITERAL(15, 174, 4), // "info"
QT_MOC_LITERAL(16, 179, 15), // "onLocationError"
QT_MOC_LITERAL(17, 195, 29), // "QGeoPositionInfoSource::Error"
QT_MOC_LITERAL(18, 225, 5), // "error"
QT_MOC_LITERAL(19, 231, 8), // "makeCall"
QT_MOC_LITERAL(20, 240, 17), // "makeEmergencyCall"
QT_MOC_LITERAL(21, 258, 16), // "sendEmergencySMS"
QT_MOC_LITERAL(22, 275, 7), // "message"
QT_MOC_LITERAL(23, 283, 16), // "triggerEmergency"
QT_MOC_LITERAL(24, 300, 20), // "startLocationUpdates"
QT_MOC_LITERAL(25, 321, 19), // "stopLocationUpdates"
QT_MOC_LITERAL(26, 341, 15) // "currentLocation"

    },
    "CallManager\0callInitiated\0\0number\0"
    "callFailed\0reason\0smsSent\0success\0"
    "emergencyTriggered\0location\0locationUpdated\0"
    "vehicleIdChanged\0vehicleId\0onPositionUpdated\0"
    "QGeoPositionInfo\0info\0onLocationError\0"
    "QGeoPositionInfoSource::Error\0error\0"
    "makeCall\0makeEmergencyCall\0sendEmergencySMS\0"
    "message\0triggerEmergency\0startLocationUpdates\0"
    "stopLocationUpdates\0currentLocation"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_CallManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      14,   14, // methods
       2,  130, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       6,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   84,    2, 0x06 /* Public */,
       4,    2,   87,    2, 0x06 /* Public */,
       6,    2,   92,    2, 0x06 /* Public */,
       8,    2,   97,    2, 0x06 /* Public */,
      10,    1,  102,    2, 0x06 /* Public */,
      11,    1,  105,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      13,    1,  108,    2, 0x08 /* Private */,
      16,    1,  111,    2, 0x08 /* Private */,

 // methods: name, argc, parameters, tag, flags
      19,    1,  114,    2, 0x02 /* Public */,
      20,    1,  117,    2, 0x02 /* Public */,
      21,    2,  120,    2, 0x02 /* Public */,
      23,    1,  125,    2, 0x02 /* Public */,
      24,    0,  128,    2, 0x02 /* Public */,
      25,    0,  129,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    3,    5,
    QMetaType::Void, QMetaType::QString, QMetaType::Bool,    3,    7,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    3,    9,
    QMetaType::Void, QMetaType::QString,    9,
    QMetaType::Void, QMetaType::QString,   12,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 14,   15,
    QMetaType::Void, 0x80000000 | 17,   18,

 // methods: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    3,   22,
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
      26, QMetaType::QString, 0x00495001,
      12, QMetaType::QString, 0x00495103,

 // properties: notify_signal_id
       4,
       5,

       0        // eod
};

void CallManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<CallManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->callInitiated((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 1: _t->callFailed((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 2: _t->smsSent((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< bool(*)>(_a[2]))); break;
        case 3: _t->emergencyTriggered((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 4: _t->locationUpdated((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 5: _t->vehicleIdChanged((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 6: _t->onPositionUpdated((*reinterpret_cast< const QGeoPositionInfo(*)>(_a[1]))); break;
        case 7: _t->onLocationError((*reinterpret_cast< QGeoPositionInfoSource::Error(*)>(_a[1]))); break;
        case 8: _t->makeCall((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 9: _t->makeEmergencyCall((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 10: _t->sendEmergencySMS((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 11: _t->triggerEmergency((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 12: _t->startLocationUpdates(); break;
        case 13: _t->stopLocationUpdates(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 6:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QGeoPositionInfo >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (CallManager::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::callInitiated)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (CallManager::*)(const QString & , const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::callFailed)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (CallManager::*)(const QString & , bool );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::smsSent)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (CallManager::*)(const QString & , const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::emergencyTriggered)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (CallManager::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::locationUpdated)) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (CallManager::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&CallManager::vehicleIdChanged)) {
                *result = 5;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<CallManager *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->currentLocation(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->vehicleId(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<CallManager *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 1: _t->setVehicleId(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject CallManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CallManager.data,
    qt_meta_data_CallManager,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *CallManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *CallManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CallManager.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int CallManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 2;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void CallManager::callInitiated(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void CallManager::callFailed(const QString & _t1, const QString & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void CallManager::smsSent(const QString & _t1, bool _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void CallManager::emergencyTriggered(const QString & _t1, const QString & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void CallManager::locationUpdated(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void CallManager::vehicleIdChanged(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
