-- 避免内存泄露
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

--设置随机数种子
math.randomseed( os.time() )