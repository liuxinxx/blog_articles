```
tags:SSM
source_title:SSM框架下各个层的解释说明
source_url:https://blog.csdn.net/lutianfeiml/article/details/51864160
```

#### 持久层：DAO层（mapper）

* DAO层：DAO层主要是做数据持久层的工作，负责与数据库进行联络的一些任务都封装在此， 
  * DAO层的设计首先是设计DAO的接口， <!--more-->
  * 然后在Spring的配置文件中定义此接口的实现类，
  * 然后就可在模块中调用此接口来进行数据业务的处理，而不用关心此接口的具体实现类是哪个类，显得结构非常清晰，
  * DAO层的数据源配置，以及有关数据库连接的参数都在Spring的配置文件中进行配置。
#### 业务层：Service层
* Service层：Service层主要负责业务模块的逻辑应用设计。 
  * 首先设计接口，再设计其实现的类
  * 接着再在Spring的配置文件中配置其实现的关联。这样我们就可以在应用中调用Service接口来进行业务处理。
  * Service层的业务实现，具体要调用到已定义的DAO层的接口，
  * 封装Service层的业务逻辑有利于通用的业务逻辑的独立性和重复利用性，程序显得非常简洁。
#### 表现层：Controller层（Handler层）
* Controller层:Controller层负责具体的业务模块流程的控制， 
  *  在此层里面要调用Service层的接口来控制业务流程，
  * 控制的配置也同样是在Spring的配置文件里面进行，针对具体的业务流程，会有不同的控制器，我们具体的设计过程中可以将流程进行抽象归纳，设计出可以重复利用的子单元流程模块，这样不仅使程序结构变得清晰，也大大减少了代码量。
#### View层
* View层 此层与控制层结合比较紧密，需要二者结合起来协同工发。View层主要负责前台jsp页面的表示.
#### 各层联系
* DAO层，Service层这两个层次都可以单独开发，互相的耦合度很低，完全可以独立进行，这样的一种模式在开发大项目的过程中尤其有优势
* Controller，View层因为耦合度比较高，因而要结合在一起开发，但是也可以看作一个整体独立于前两个层进行开发。这样，在层与层之前我们只需要知道接口的定义，调用接口即可完成所需要的逻辑单元应用，一切显得非常清晰简单。
* Service逻辑层设计
  * Service层是建立在DAO层之上的，建立了DAO层后才可以建立Service层，而Service层又是在Controller层之下的，因而Service层应该既调用DAO层的接口，又要提供接口给Controller层的类来进行调用，它刚好处于一个中间层的位置。每个模型都有一个Service接口，每个接口分别封装各自的业务处理方法。
#### SSM框架整合说明
#### **整合Dao层**
#### MyBatis配置文件 `sqlMapConfig.xml`
* 配置别名：用于批量扫描Pojo包
* 不需要配置mappers标签，但一定要保证mapper.java文件与mapper.xml文件同名。
```xml
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">  
    <configuration> 
        <!-- 配置别名 -->  
        <typeAliases>  <!-- 批量扫描别名 -->  
            <package name="cn.itcast.ssm.po"/>  
        </typeAliases>  
    </configuration>
```
#### Spring配置文件 `applicationContext-dao.xml`
* **主要配置内容**
  * 数据源
  * SqlSessionFactory
* mapper扫描器 
  * 这里使用sqlSessionFactoryBeanName属性是因为如果配置的是sqlSessionFactory属性，将不会先加载数据库配置文件及数据源配置
```xml
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mvc="http://www.springframework.org/schema/mvc"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="http://www.springframework.org/schema/beans 
        http://www.springframework.org/schema/beans/spring-beans-3.2.xsd 
        http://www.springframework.org/schema/mvc 
        http://www.springframework.org/schema/mvc/spring-mvc-3.2.xsd 
        http://www.springframework.org/schema/context 
        http://www.springframework.org/schema/context/spring-context-3.2.xsd 
        http://www.springframework.org/schema/aop 
        http://www.springframework.org/schema/aop/spring-aop-3.2.xsd 
        http://www.springframework.org/schema/tx 
        http://www.springframework.org/schema/tx/spring-tx-3.2.xsd ">
    <!-- 加载db.properties文件中的内容，db.properties文件中key命名要有一定的特殊规则 -->
    <context:property-placeholder location="classpath:db.properties" />
    <!-- 配置数据源 ，dbcp -->
    
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="${jdbc.driver}" />
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
        <property name="maxActive" value="30" />
        <property name="maxIdle" value="5" />
    </bean>
    
    <!-- sqlSessionFactory -->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <!-- 数据库连接池 -->
        <property name="dataSource" ref="dataSource" />
        <!-- 加载mybatis的全局配置文件 -->
        <property name="configLocation" value="classpath:mybatis/sqlMapConfig.xml" />
    </bean>
    
    <!-- mapper扫描器 -->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <!-- 扫描包路径，如果需要扫描多个包，中间使用半角逗号隔开 -->
        <property name="basePackage" value="cn.itcast.ssm.mapper"></property>
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory" />
    </bean>
</beans>
```

#### 创建所需的 `Mapper.java`

* 一般不动原始生成的po类，而是将原始类进行集成vo类

```java
public interface ItemsMappperCustom{
    public List<ItemsCustom> findItemsList(ItemsQueryVo itemsQueryVo) throws Exception;
}
```

#### 创建POJO类对应的 `mapper.xml`

```xml
<mapper namespace="test.ssm.mapper.ItemsMappperCustom">
    <select id="findItemsList" parameterTyep="test.ssm.po.ItemsQueryVo" resultType="test.ssm.po.ItemsCustom">
    select items.* from items
    where items.name like '%${itemsCustom.name}%'
```



#### 整合service层

* 目标：让spring管理service接口。
#### 定义service接口
* 一般在ssm.service包下定义接口 eg：ItemsService

```java
public interfae ItemsService{
    public List<ItemsCustom> findItemsList(ItemsQueryVo itemsQueryVo) throws Exception;
}
```

#### 定义ServiceImpl实现类

* 因为在`applicationContext-dao.xml`中已经使用了mapper扫描器，这里可以直接通过注解的方式将itemsMapperCustom自动注入。

```java
public class ItemsServiceImpl implements ItemsService{
    @Autowired
    private ItemsMapperCustom itemsMapperCustom;
    
    @Override
    public List<ItemsCustom> findItemsList(ItemsQueryVo itemsQueryVo) throws Exception{
        return itemsMapperCustom.findItemsList(itemsQueryVo);
    }
}
```

#### 在spring容器配置service

* `applicationContext-service.xml`在此文件中配置service。

```
<bean id="itemsService" class="test.ssm.service.impl.ItemsSrviceImpl"/>
```

#### 事物控制（不够熟悉）

* 在`applicationContext-transaction.xml`中使用spring声明式事务控制方法
* 对mybatis操作数据库事物控制，spring使用jdbc的事物控制类是`DataSourceTransactionManager`
* 因为操作了数据库需要事物控制，所以需要配置数据源
* 定义了切面

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mvc="http://www.springframework.org/schema/mvc"
    xmlns:context="http://www.springframework.org/schema/context"
    xmlns:aop="http://www.springframework.org/schema/aop" xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="http://www.springframework.org/schema/beans 
        http://www.springframework.org/schema/beans/spring-beans-3.2.xsd 
        http://www.springframework.org/schema/mvc 
        http://www.springframework.org/schema/mvc/spring-mvc-3.2.xsd 
        http://www.springframework.org/schema/context 
        http://www.springframework.org/schema/context/spring-context-3.2.xsd 
        http://www.springframework.org/schema/aop 
        http://www.springframework.org/schema/aop/spring-aop-3.2.xsd 
        http://www.springframework.org/schema/tx 
        http://www.springframework.org/schema/tx/spring-tx-3.2.xsd ">
<!-- 事务管理器 对mybatis操作数据库事务控制，spring使用jdbc的事务控制类 -->
<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <!-- 数据源在 dataSource在applicationContext-dao.xml中已经配置-->
    <property name="dataSource" ref="dataSource"/>
</bean>
<!-- 通知 -->
<tx:advice id="txAdvice" transaction-manager="transactionManager">
    <tx:attributes>
        <!-- 传播行为 -->
        <tx:method name="save*" propagation="REQUIRED"/>
        <tx:method name="delete*" propagation="REQUIRED"/>
        <tx:method name="insert*" propagation="REQUIRED"/>
        <tx:method name="update*" propagation="REQUIRED"/>
        <tx:method name="find*" propagation="SUPPORTS" read-only="true"/>
        <tx:method name="get*" propagation="SUPPORTS" read-only="true"/>
        <tx:method name="select*" propagation="SUPPORTS" read-only="true"/>
    </tx:attributes>
</tx:advice>
<!-- aop -->
<aop:config>
    <aop:advisor advice-ref="txAdvice" pointcut="execution(* cn.itcast.ssm.service.impl.*.*(..))"/>
</aop:config>
</beans>
```

#### 整合springmvc

* 创建`springmvc.xml`文件，配置处理器映射器 、 适配器、视图解析器

```xml
<context:component-scan base-package="cn.itcast.ssm.controller"></context:component-scan>
<!-- 使用 mvc:annotation-driven 加载注解映射器和注解适配器配置-->
<mvc:annotation-driven></mvc:annotation-driven>
<!-- 视图解析器 解析jsp解析，默认使用jstl标签，classpath下的得有jstl的包
 -->
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <!-- 配置jsp路径的前缀 -->
    <property name="prefix" value="/WEB-INF/jsp/"/>
    <!-- 配置jsp路径的后缀 -->
    <property name="suffix" value=".jsp"/>
</bean>
```

#### 配置前端控制器

* 在`web.xml`中加入如下内容
* `contextConfigLocation`配置springmvc加载的配置文件（配置处理器映射器、适配器等等） 
  如果不配置contextConfigLocation，默认加载的是**/WEB-INF/servlet**名称-`serlvet.xml（springmvc-servlet.xml）`
* 在url-pattern中 
  * 填入*.action，表示访问以.action结尾 由DispatcherServlet进行解析
  * 填入/，所有访问的地址都由DispatcherServlet进行解析，对于静态文件的解析需要配置不让DispatcherServlet进行解析，使用此种方式可以实现**RESTful风格的url**

```xml
<!-- springmvc前端控制器 -->
    <servlet>
        <servlet-name>springmvc</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring/springmvc.xml</param-value>
        </init-param>
    </servlet>
<servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <url-pattern>*.action</url-pattern>
</servlet-mapping>
```

#### 编写Controller（Handler）

```java
@Congtroller
@RequestMapping("/items") //窄化路径
public class ItemsController {
    @Autowired
    private ItemsService itemsService;
    //商品查询
    @RequestMapping("/queryItems") //实际网址后面跟了.action
    public ModelAndView queryItems(HttpServletRequest request) throws Exception {
        List<ItemsCustom> itemsList = itemsService.findItemsList(null);
    
        //返回ModelAndView
        ModelAndView modelAndView = new ModelAndView();
    
        //相当于request的setAttribute，在jsp页面中通过itemsList取数据
        modelAndView.addObject("itemsList",itemsList);
    
        return modelAndView;
    }
}
```
#### 编写JSP页面

```jsp
<c:forEach items="${itemsList }" var="item">
<tr>
    <td>${item.name }</td>
    <td>${item.price }</td>
    <td><fmt:formatDate value="${item.createtime}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
    <td>${item.detail }</td>
    <td><a href="${pageContext.request.contextPath }/items/editItems.action?id=${item.id}">修改</a></td>
</tr>
</c:forEach>
加载spring容器
在web.xml中，添加spring容器监听器，加载spring容器
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>/WEB-INF/classes/spring/applicationContext-*.xml</param-value>
</context-param>
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
<listener>
```