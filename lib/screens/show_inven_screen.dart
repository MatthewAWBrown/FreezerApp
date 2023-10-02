import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/inven_provider.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';

class ShowInvenScreen extends StatelessWidget {
  const ShowInvenScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final invenP = Provider.of<InvenProvider>(context, listen: false);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Freezer Inventory'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  useSafeArea: true,
                  context: context,
                  builder: (context) => AlertDialog(
                    scrollable: true,
                    title: const Text('Delete All'),
                    content: const Text('Do you want to delete all data?'),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(width*0.02),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                  onPressed: () async {
                                    await invenP.deleteTable();
                                    Navigator.pop(context);
                                  }, child: Text('Yes',
                                    style: TextStyle(
                                    color: Theme.of(context).primaryColor)
                                ),
                                ),
                              )
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(width*0.02),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, child: Text(
                                'No',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),);
            },
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.white,
            )
          ),
        ],
      ),

      body: FutureBuilder(
        future: Provider.of<InvenProvider>(context, listen: false).selectData(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            return Consumer<InvenProvider>(
              builder: (context, invenProvider, child) {
                return invenProvider.invenItem.isNotEmpty?ListView.builder(
                  itemCount: invenProvider.invenItem.length,
                  itemBuilder: (context, index) {
                    final helperValue = invenProvider.invenItem[index];
                    return Dismissible(
                      key: ValueKey(helperValue.id),
                      background: Container(
                        margin: EdgeInsets.all(width*0.01),
                        padding: EdgeInsets.all(width*0.03),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(width*0.03),
                        ),
                        alignment: Alignment.centerLeft,
                        height: height*0.02,
                        width: width,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        padding: EdgeInsets.all(width*0.03),
                        margin: EdgeInsets.all(width*0.01),
                        width: width,
                        height: height*0.02,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(width*0.03),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        if(direction == DismissDirection.startToEnd) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => EditItemScreen(
                                  id: helperValue.id,
                                  title: helperValue.title,
                                  count: helperValue.count,
                                  date: helperValue.date
                                ),
                            )
                          );
                        } else {
                          showDialog(
                            useSafeArea: true,
                            context: context,
                            builder: (context) => AlertDialog(
                              scrollable: true,
                              title: const Text('Delete'),
                              content: const Text('Do you want to delete this item?'),
                              actions: [
                                ElevatedButton(
                                    onPressed: (){
                                      invenProvider.deleteById(helperValue.id);
                                      invenProvider.invenItem.remove(helperValue);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes')
                                ),
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text('No')
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Card(
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          title: Text(
                            helperValue.title
                          ),
                          subtitle: Text(
                            helperValue.date
                          ),
                          // trailing: Text(
                          //   helperValue.date
                          // ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.exposure_minus_1_outlined),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  helperValue.count
                                ),
                              ),
                              Icon(Icons.exposure_plus_1_outlined),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ): const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 180.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'The freezer is empty and beans are hungry',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
    );
  }
}
