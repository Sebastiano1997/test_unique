//```dart
// <HistoryObj>
class HistoryObj<T> {
HistoryObj(this.id, this.seq, this._item);

HistoryObj.refItem(this.id, this.seq, this.getItem);

int id;
int seq;
bool isRemoved = false;
T? _item;
T? get item=> _item??getItem?.call();
set item(value)=> _item=value;

T Function()? getItem;
}
// </HistoryObj>

// <ICopyT>
abstract class ICopyT<T> {
T copy(T item);
}
// </ICopyT>

// <IHistoryObjFather>
abstract class IHistoryObjFather<T extends ICopyT<T>> {
bool addHistory( T Function() getItem, {bool isRemoved = false});
HistoryObj<T>? back(T item);
HistoryObj<T>? after(T item);
bool removeAllHistory(T item);
int? getIdFromItem(T item);
int getNextId();
}
// </IHistoryObjFather>

// <HistoryObjFather>
class HistoryObjFather<T extends ICopyT<T>> implements IHistoryObjFather<T> {
final List<HistoryObj<T>> listHistory = [];

@override
bool addHistory(T Function() getItem, {bool isRemoved = false}) {
bool isNew = false;
T itemFreeze=getItem();

HistoryObj<T>? itemCurrentHistory = listHistory.where(
(i) => i.item == getItem()//, orElse: () => null as HistoryObj<T>,
).firstOrNull;

late HistoryObj<T> itemFreezHistory;
int id;

if (itemCurrentHistory == null) {
id = getNextId();
itemCurrentHistory = HistoryObj<T>.refItem(id, 1, getItem);
//itemFreeze//final T itemFreez = item.copy(item);
itemFreezHistory = HistoryObj<T>(id, 1, itemFreeze);
isNew = true;
} else {
id = itemCurrentHistory.id;
//final T itemFreez = item.copy(item);
itemFreezHistory =
HistoryObj<T>(id, itemCurrentHistory.seq, itemFreeze);
itemCurrentHistory.seq++;
}

if (isRemoved) {
itemCurrentHistory.isRemoved = true;
itemCurrentHistory.item = null;
}

if (isNew) listHistory.add(itemCurrentHistory);
listHistory.add(itemFreezHistory);

listHistory.removeWhere((i) => i.id == id && i.seq < 0);

return true;
}

@override
HistoryObj<T>? back(T item) {
final int? id = getIdFromItem(item);
if (id == null) return null;

final listItems = listHistory.where((i) => i.id == id).toList();
final int max = listItems.map((i) => i.seq).reduce((a, b) => a > b ? a : b);
final int min = listItems.map((i) => i.seq).reduce((a, b) => a < b ? a : b);

int index = 0;
if (max - 1 > 0) index = max - 1;

final itemCurrent =
listItems.firstWhere((i) => i.seq == max, orElse: () => null as HistoryObj<T>);
final itemBack =
listItems.firstWhere((i) => i.seq == index, orElse: () => null as HistoryObj<T>);

if (itemCurrent != null) {
itemCurrent.seq = min - 1;
itemCurrent.item = itemCurrent.item?.copy(itemCurrent.item as T);
}

return itemBack;
}

@override
HistoryObj<T>? after(T item) {
final int? id = getIdFromItem(item);
if (id == null) return null;

final listItems = listHistory.where((i) => i.id == id).toList();
final int max = listItems.map((i) => i.seq).reduce((a, b) => a > b ? a : b);
final int min = listItems.map((i) => i.seq).reduce((a, b) => a < b ? a : b);

if (min < 0) {
final itemAfter =
listItems.firstWhere((i) => i.seq == min, orElse: () => null as HistoryObj<T>);
if (itemAfter != null) {
itemAfter.seq = max + 1;
return itemAfter;
}
}
return null;
}

@override
bool removeAllHistory(T item) {
final int? id = getIdFromItem(item);
if (id == null) return false;
listHistory.removeWhere((i) => i.id == id);
return true;
}

@override
int? getIdFromItem(T item) {
final itemHistory =
listHistory.firstWhere((i) => i.item == item, orElse: () => null as HistoryObj<T>);
return itemHistory?.id;
}

@override
int getNextId() {
if (listHistory.isEmpty) return 1;
final idLast =
listHistory.map((i) => i.id).reduce((a, b) => a > b ? a : b);
return idLast + 1;
}
}
// </HistoryObjFather>
//```
