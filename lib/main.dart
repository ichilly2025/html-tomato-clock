import 'package:flutter/material.dart';

void main() {
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // 使用深橙色作为主题色
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PomodoroTimerPage(),
    );
  }
}

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  // 计时器相关变量
  int _totalSeconds = 25 * 60; // 默认25分钟（以秒为单位）
  bool _isRunning = false; // 计时器是否正在运行
  bool _isWorkMode = true; // true: 工作模式, false: 休息模式
  late Timer _timer; // 计时器对象

  // 工作模式和休息模式的时间设置（秒）
  static const int workTime = 25 * 60; // 25分钟
  static const int breakTime = 5 * 60; // 5分钟

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 开始计时器
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_totalSeconds > 0) {
          _totalSeconds--;
        } else {
          // 计时结束
          _timer.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  // 暂停计时器
  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer.cancel();
  }

  // 重置计时器
  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _totalSeconds = _isWorkMode ? workTime : breakTime;
    });
    _timer.cancel();
  }

  // 切换工作/休息模式
  void _toggleMode() {
    setState(() {
      _isWorkMode = !_isWorkMode;
      _totalSeconds = _isWorkMode ? workTime : breakTime;
      _isRunning = false;
    });
    _timer.cancel();
  }

  // 显示计时完成对话框
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isWorkMode ? '工作完成！' : '休息结束！'),
        content: Text(_isWorkMode
            ? '25分钟专注时间已结束，该休息5分钟了！'
            : '5分钟休息时间已结束，准备开始下一轮工作吧！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleMode(); // 自动切换到另一种模式
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 格式化时间显示（MM:SS）
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusFlow 番茄钟'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 模式指示器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isWorkMode ? Colors.deepOrange : Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWorkMode ? '工作模式' : '休息模式',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // 倒计时显示器
            Text(
              _formatTime(_totalSeconds),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w300,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            
            // 计时器状态提示
            Text(
              _isWorkMode ? '专注工作 25 分钟' : '放松休息 5 分钟',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 50),
            
            // 控制按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 开始/暂停按钮
                ElevatedButton(
                  onPressed: () {
                    if (_isRunning) {
                      _pauseTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isRunning ? '暂停' : '开始',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 20),
                
                // 重置按钮
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    side: const BorderSide(color: Colors.deepOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '重置',
                    style: TextStyle(fontSize: 18, color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // 模式切换按钮
            ElevatedButton.icon(
              onPressed: _toggleMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.withOpacity(0.1),
                foregroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_isWorkMode ? Icons.coffee : Icons.work),
              label: Text(
                _isWorkMode ? '切换到休息模式' : '切换到工作模式',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      // 底部信息栏
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'FocusFlow - 专注工作，高效生活',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
