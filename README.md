# mxc_router
    用法：
    1.在pubspec.yaml中引入：
        mxc_router:
            git:
                url: git@github.com:aa41/mxc_router.git
                ref: master


   2.在页面上添加注解：

        @MRouter(
            url = 'test://abc/test',//路由url
            aliasNames = ['testA','/'],//别名
            desc = '这是个测试例子',//页面描述
            params = {
            'a': String, //支持type传递，
            'b':'abc', //同样支持直接字符串
            'c':TestModel //自定义类型同样支持
            },//路由参数
        )
        class Main{}

   3.新建类名**.router.dart文件，并添加注解：

        @MXCWriterRouter()
        class Router{}


   4.执行  flutter packages pub run build_runner clean && flutter packages pub run build_runner build 生成dart文件

   5.将注释相应代码copy到Router相对应的位置。在 MaterialApp onGenerateRoute中注册 MXCRouter.instance.routeFactory;


   6.在做跳转操作时即可使用：context.pushToAbcTest($a:'a',$b:'b',$c: TestModel()); (abcTest == 注解中url path部分)获取当前路由参数可使用context.argumentsAbcTest();