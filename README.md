# libxd

A libx-esque Collection infrastructure for MobX applications. Based off of [libx](https://github.com/jeffijoe/libx) by jeffijoe.

## Collection

> "I hate regular lists, I'm always getting duplicate items" - 733T-Hck3r-man-27

> "How can anyone possibly maintain a list of objects and dynamically update them in realtime?!" - Tom Cruise

Well not to fear my friends, libxd is here!

libxd maintains a collection of items, making sure we only have a single instance of an entity in memory. It even uses Mobx! That way, updates to an entity will propagate to the entire system without us having to do anything at all.

## Getting started

Be sure to install the latest `build_runner` pakcage and run `flutter packages pub run build_runner build`. This is used to generate the needed `mobx_codegen` files.

## Why use Collections?

The libxd `Collection` allows us to easily manage a list of any model type. It can ensure each item is unique based on the model ID.

libxd uses the `mobx_dart` package to ensure changes to the collection items can be observed and can propagate on your app in realtime.

## Specifying a Model ID

Each item is required to have an ID variable. By default `libxd` tries to access the `id` param on your object (aka `item.id`). You can specify which field is your ID by overriding the `getModelId` method when instantiating your `Collection`.

```dart
Collection<Car> cars = Collection<Car>(
    getModelId: (c) => c.vinNumber
);
```

Now everytime you add a new `Car` to your `Collection` it will ensure it is unique by it's VIN number.

## Setting Objects

Ok, so how do we go about updating and adding things to our `Collection`?

For example, lets say we have a `User` model:

```dart
class User {
    String id;
    String name;
    String email;
}
```

We can easily add items and update items in our collection by using the `set` or `setAll` methods:

```dart
Collection<User> users = Collection<User>();

final someApiRequest = await dio.get('/users');
final result = someApiRequest.data.map((json) => User.fromJson(json));

users.setAll(result);
```

This will add all `User` objects to our collection and update any duplicates.

> **Note**: we don't need to specify `getModelId` since our class has an `id` field.

## Sorting the Collection

Say I have a list of objects that need to be ordered based on a specific field. Well libxd does that!

Simply specify the `sortBy` field when instantiating a new `Collection`:

```dart
Collection<Messages> messages = Collection<Messages>(
    sortBy: CollectionSort<Messages>((m) => m.dateSent.toString(), 'desc'),
);
```

Now, whenever the items in the collection are updated, the collection will be sorted accordingly.

> "Ok, but I don't want to sort every time the collection is updated..." - anonymous user

Well not to fear, we got you covered!

Just call `sort` on your collection and specify the field to be sorted on.

```dart
notifications.sort((n) => n.dateCreated.toString(), 'asc');
```

## Removing Objects

libxd makes it super simple to remove objects from your collection.

### Remove by Reference

```dart
final item = SomeItem();
collection.set(item);

collection.remove(item);
```

### Remove by ID

```dart
collection.removeById(item.userId);
```

## Clearing the Collection

Empties the collection and preps it to receive new items.

```dart
collection.clear()
```

## Some nice to have methods

### Move Item

> "I'm implementing some sweet drag n' drop funcitonality, but I have to do this convoluted code to move things around in my list... pls help!" - noob coder

Not to worry, libxd has your back!

Simply call `move` and specify your `from` index and `to` index.

```dart
collection.move(2, 7);
```

## Original libx Package

Creator: [jeffijoe](https://github.com/jeffijoe)

Github: https://github.com/jeffijoe/libx
