```
tags:other
```



## 什么是 API 级别？

API 级别是一个对 Android 平台版本提供的框架 API 修订版进行唯一标识的整数值。

Android 平台提供了一种框架 API，应用可利用它与底层 Android 系统进行交互。 该框架 API 由以下部分组成：

- 一组核心软件包和类
- 一组用于声明清单文件的 XML 元素和属性
- 一组用于声明和访问资源的 XML 元素和属性
- 一组 Intent
- 一组应用可请求的权限，以及系统中包括的权限强制执行。
- 每个后续版本的 Android 平台均可包括对其提供的 Android 应用框架 API 的更新。

框架 API 更新的设计用途是使新 API 与早期版本的 API 保持兼容。 也就是说，大多数 API 更改都是新增更改，会引入新功能或替代功能。 在 API 的某些部分得到升级时，旧版的被替换部分将被弃用，但不会被移除，这样现有应用仍可使用它们。 在极少数情况下，可能会修改或移除 API 的某些部分，但通常只有在为了确保 API 稳健性以及应用或系统安全性时，才需要进行此类更改。 所有其他来自早期修订版的 API 部分都将结转，不做任何修改。

Android 平台提供的框架 API 使用叫做“API 级别”的整数标识符指定。 每个 Android 平台版本恰好支持一个 API 级别，但隐含了对所有早期 API 级别（低至 API 级别 1）的支持。 Android 平台初始版本提供的是 API 级别 1，后续版本的 API 级别递增。

下表列出了各 Android 平台版本支持的 API 级别。
| 平台版本                  | API 级别 | VERSION_CODE           |
| ------------------------- | -------- | ---------------------- |
| Android 8.1               | 27       | Oreo                   |
| Android 8                 | 26       | Oreo                   |
| Android 7.1               | 25       | Nougat                 |
| Android 7.0               | 24       | Nougat                 |
| Android 6.0               | 23       | Marshmallow            |
| Android 5.1               | 22       | LOLLIPOP_MR1           |
| Android 5.0               | 21       | LOLLIPOP               |
| Android 4.4W              | 20       | KITKAT_WATCH           |
| Android 4.4               | 19       | KITKAT                 |
| Android 4.3               | 18       | JELLY_BEAN_MR2         |
| Android 4.2、4.2.2        | 17       | JELLY_BEAN_MR1         |
| Android 4.1、4.1.1        | 16       | JELLY_BEAN             |
| Android 4.0.3、4.0.4      | 15       | ICE_CREAM_SANDWICH_MR1 |
| Android 4.0、4.0.1、4.0.2 | 14       | ICE_CREAM_SANDWICH     |
| Android 3.2               | 13       | HONEYCOMB_MR2          |
| Android 3.1.x             | 12       | HONEYCOMB_MR1          |
| Android 3.0.x             | 11       | HONEYCOMB              |
| Android 2.3.3、2.3.4      | 10       | GINGERBREAD_MR1        |
| Android 2.3、2.3.1、2.3.2 | 9        | GINGERBREAD            |
| Android 2.2.x             | 8        | FROYO                  |
| Android 2.1.x             | 7        | ECLAIR_MR1             |
| Android 2.0.1             | 6        | ECLAIR_0_1             |
| Android 2.0               | 5        | ECLAIR                 |
| Android 1.6               | 4        | DONUT                  |
| Android 1.5               | 3        | CUPCAKE                |
| Android 1.1               | 2        | BASE_1_1               |
| Android 1.0               | 1        | BASE                   |