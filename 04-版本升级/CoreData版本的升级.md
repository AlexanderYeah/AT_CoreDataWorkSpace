CoreData版本的迁移



### 

#### 一  轻量级的数据迁移

例如添加新的实体，新的实体属性。

轻量级版本迁移方案非常简单，大多数迁移工作都是由系统完成的，只需要告诉系统迁移方式即可。在持久化存储协调器(`PSC`)初始化对应的持久化存储(`NSPersistentStore`)对象时，设置`options`参数即可，参数是一个字典。`PSC`会根据传入的字典，自动推断版本迁移的过程。



#### 1 新建一个版本的数据库模型

   选中需要做迁移的模型文件 --> Editor --> Add model Version

#### 2 在右边栏 设置当前的coredata 数据模型为新建的那个数据模型

#### ![](https://img02.sogoucdn.com/app/a/100520146/ABD1A64BE16FEE83A8D864AF98E8703D)



#### 3 修改新的数据模型 增加字段 增加实体 修改属性名 实体名 均可 

增加字段 增加实体直接增加即可，如果是修改实体的名字，则需要按照如下的设置

并且在代码中吗，使用旧实体的时候换成新的实体


![](![](https://ws3.sinaimg.cn/large/005BYqpgly1fyt7k1x30oj30730fjgmc.jpg))



####  4 删除旧的实体类，重新生成新的实体类

####  5 设置`options`参数即可，打开数据库升级迁移的开关

NSMigratePersistentStoresAutomaticallyOption 告知协调器  如果持久存储不兼当前的模型，则自动迁移当前的新模型。

NSInferMappingModelAutomaticallyOption 让其利用可以打开现有的数据存储的模型和当前模型之间的不同之处来推断映射模型。





`NSMigratePersistentStoresAutomaticallyOption`设置为`YES`，`CoreData`会试着把低版本的持久化存储区迁移到最新版本的模型文件。

`NSInferMappingModelAutomaticallyOption`设置为`YES`，`CoreData`会试着以最为合理地方式自动推断出源模型文件的实体中，某个属性到底对应于目标模型文件实体中的哪一个属性。

```objective-c
    // 轻量级数据库迁移的时候设置对应的参数
    NSDictionary *dic =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,[NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
```





打印调试参数：

打开Product，选择Edit Scheme.
选择Arguments，在下面的ArgumentsPassed On Launch中添加下面两个选项，如图：
(1)-com.apple.CoreData.SQLDebug
(2)1