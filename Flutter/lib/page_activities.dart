import 'package:codecolab_timetracker/tree.dart';
import 'package:flutter/material.dart';
import 'package:codecolab_timetracker/PageIntervals.dart';

class PageActivities extends StatefulWidget {
  int id;

  PageActivities(this.id);
  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  Tree tree;

  @override
  void initState() {
    super.initState();
    tree = getTree();
  }
  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tree.root.name),
        actions: <Widget>[
      IconButton(icon: Icon(Icons.home),
        onPressed: () {
          while(Navigator.of(context).canPop()) {
            print("pop");
            Navigator.of(context).pop();
          }
          /* this works also:
  Navigator.popUntil(context, ModalRoute.withName('/'));
  */
          PageActivities(0);
        }),
          //TODO other actions
        ],
      ),
      body: ListView.separated(
        // it's like ListView.builder() but better
        // because it includes a separator between items
        padding: const EdgeInsets.all(16.0),
        itemCount: tree.root.children.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildRow(tree.root.children[index], index),
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(),
      ),
    );
  }

  void _navigateDownIntervals(int childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(),
    )).then( (var value) {
      _refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateDownActivities(int childId) {
    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId),
    )).then( (var value) {
      _refresh();
    });
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list
    // removes the microseconds part
    if (activity is Project) {
      return ListTile(
        title: Text('${activity.name}'),
        trailing: Text('$strDuration'),
        onTap: () => _navigateDownActivities(index),
      );
    } else if (activity is Task) {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text('$strDuration');
      return ListTile(
        title: Text('${activity.name}'),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(index),
        onLongPress: () {
        if (task.active) {
          stop(activity.id);
          _refresh();
        } else {
          start(activity.id);
          _refresh();
        }
      },
      );
    }
  }
}
