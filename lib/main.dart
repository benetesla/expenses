import 'dart:io';
import 'dart:math';

import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transction_form.dart';
import 'package:expenses/components/transction_list.dart';
import 'package:expenses/model/transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.purple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  var showChart = false;

  List<Transaction> get _recentTransaction {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  void _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });
    Navigator.of(context).pop();
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  void _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    PreferredSizeWidget appBar;
    if (Platform.isIOS) {
      appBar = CupertinoNavigationBar(
        middle: const Text('Despesas Pessoais'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _openTransactionFormModal(context),
              child: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
      );
    } else {
      appBar = AppBar(
        title: const Text('Despesas Pessoais'),
        actions: [
          IconButton(
            onPressed: () => _openTransactionFormModal(context),
            icon: const Icon(Icons.add),
          ),
          if (isLandscape)
            IconButton(
              onPressed: () {
                setState(() {
                  showChart = !showChart;
                });
              },
              icon: Icon(showChart ? Icons.list : Icons.show_chart),
            ),
        ],
      );
    }

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;
    Widget bodyPage;

    if (Platform.isIOS) {
      bodyPage = CupertinoPageScaffold(
        navigationBar: appBar as ObstructingPreferredSizeWidget?,
        child: _buildBody(isLandscape, availableHeight),
      );
    } else {
      bodyPage = Scaffold(
        appBar: appBar as PreferredSizeWidget?,
        body: _buildBody(isLandscape, availableHeight),
        floatingActionButton: Platform.isIOS
            ? Container()
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _openTransactionFormModal(context),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    return bodyPage;
  }

  Widget _buildBody(bool isLandscape, double availableHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showChart || !isLandscape)
            Container(
              height: availableHeight * (isLandscape ? 0.7 : 0.3),
              child: Chart(recentTransaction: _recentTransaction),
            ),
          if (!showChart || !isLandscape)
            Container(
              height: availableHeight * (isLandscape ? 1 : 0.7),
              child: TransactionList(_transactions, _deleteTransaction),
            ),
        ],
      ),
    );
  }
}
