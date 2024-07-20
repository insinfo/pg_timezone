# pg_timezone

This package is based on the timezone package modified to be optimized to work internally in the postgresql driver, with the modifications there is no need for initialization.

This package provides the [IANA time zone database] and time zone aware
`DateTime` class, [`TZDateTime`].

The current time zone database version is [2024a]

You can update to the current IANA time zone database by running
`tool/refresh.sh`.


### Database variants

We offer three different variants of the IANA database:

- **default**: doesn't contain deprecated and historical zones with some
  exceptions like "US/Eastern" and "Etc/UTC"; this is about 75% the size of the
  **all** database.
- **all**: contains all data from the [IANA time zone database].
- **10y**: default database truncated to contain historical data from 5 years 
  ago until 5 years in the future; this database is about 25% the size of the
  default database.


## API

### Library Namespace

The public interfaces expose several top-level functions. It is recommended
then to import the libraries with a prefix (the prefix `tz` is common), or to
import specific members via a `show` clause.

### Location

> Each location in the database represents a national region where all
> clocks keeping local time have agreed since 1970. Locations are
> identified by continent or ocean and then by the name of the
> location, which is typically the largest city within the region. For
> example, America/New_York represents most of the US eastern time
> zone; America/Phoenix represents most of Arizona, which uses
> mountain time without daylight saving time (DST); America/Detroit
> represents most of Michigan, which uses eastern time but with
> different DST rules in 1975; and other entries represent smaller
> regions like Starke County, Indiana, which switched from central to
> eastern time in 1991 and switched back in 2006.
>
> [The tz database](https://www.iana.org/time-zones)

#### Get location by tz database/Olson name

```dart
final detroit = tz.getLocation('America/Detroit');
```

See [Wikipedia list] for more database entry names.

We don't provide any functions to get locations by time zone abbreviations
because of the ambiguities.

> Alphabetic time zone abbreviations should not be used as unique identifiers
> for UTC offsets as they are ambiguous in practice. For example, "EST" denotes
> 5 hours behind UTC in English-speaking North America, but it denotes 10 or 11
> hours ahead of UTC in Australia; and French-speaking North Americans prefer
> "HNE" to "EST".
>
> [The tz database](https://www.iana.org/time-zones)

### TimeZone

TimeZone objects represents time zone and contains offset, DST flag, and name
in the abbreviated form.

```dart
var timeInUtc = DateTime.utc(1995, 1, 1);
var timeZone = detroit.timeZone(timeInUtc.millisecondsSinceEpoch);
```

### TimeZone aware DateTime

The `TZDateTime` class implements the `DateTime` interface from `dart:core`,
and contains information about location and time zone.

```dart
var date = tz.TZDateTime(detroit, 2014, 11, 17);
```

#### Converting DateTimes between time zones

To convert between time zones, just create a new `TZDateTime` object using
`from` constructor and pass `Location` and `DateTime` to the constructor.

```dart
var localTime = tz.DateTime(2010, 1, 1);
var detroitTime = tz.TZDateTime.from(localTime, detroit);
```

This constructor supports any objects that implement `DateTime` interface, so
you can pass a native `DateTime` object or our `TZDateTime`.

## <a name="databases"></a> Time Zone databases

We are using [IANA Time Zone Database](http://www.iana.org/time-zones)
to build our databases.

We currently build three different database variants:

- default (doesn't contain deprecated and historical zones with some exceptions
  like US/Eastern). 361kb
- all (contains all data from the [IANA time zone database]). 443kb
- 10y (default database that contains historical data from the last and future 5
  years). 85kb

### Updating Time Zone databases

Script for updating Time Zone database, it will automatically download the
[IANA time zone database] and compile into our native format.

```sh
$ chmod +x tool/refresh.sh
$ tool/refresh.sh
```

Note, on Windows, you may need to follow these steps:

On Windows 10, install / fire up Ubuntu on Windows Subsystem for Linux (WSL). Then in the ubuntu shell window:

Install Dart and add to PATH
sudo apt-get update
sudo apt-get install apt-transport-https
sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt-get update
sudo apt-get install dart
echo 'export PATH="$PATH:/usr/lib/dart/bin"' >> ~/.profile
Close the Ubuntu / WSL window, and open it up again, so the PATH changes are applied.

Clone the timezone repo and run the tool
git clone https://github.com/srawlins/timezone.git
cd timezone
pub run tool/get -s 2020a
replace 2020a with the latest version
Copy files to Windows file system
The timezone databases are generated and stored in lib/data in the timezone folder on WSL, so copy them from the WSL filesystem to your flutter project on your Windows file system. I chose to put them in a folder called assets in the root of my project:

mv lib/data/2020a* /mnt/d/code/my-flutter-project/assets/timezone/


[2024a]: https://data.iana.org/time-zones/releases/tzdb-2024a.tar.lz
[IANA time zone database]: https://www.iana.org/time-zones
[Wikipedia list]: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
