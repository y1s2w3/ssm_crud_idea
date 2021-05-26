package com.ysw.crud.handler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;
import javax.validation.metadata.ValidateUnwrappedValue;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.ysw.crud.bean.Employee;
import com.ysw.crud.bean.Msg;
import com.ysw.crud.service.EmployeeService;

/**
 *	处理与员工相关请求的处理器
 * @author Administrator
 *
 */
@Controller
public class EmployeeController {
	
	@Autowired
	private EmployeeService employeeService;
	
	/**
	 *	查询所有员工（分页查询）
	 *	引入 PageHelper 分页插件
	 *		1、引入 jar 包依赖
	 *		2、在 mybatis 全局配置文件中引入插件
	 *		3、调用 PageHelper.startPage(pageNum, pageSize) 方法
	 */
//	@RequestMapping("/emps")
//	public String getEmps(@RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum, Model model) {
//		PageHelper.startPage(pageNum, 5);
//		List<Employee> employees = employeeService.getEmployees();
//		// 使用 PageInfo 包装查询结果，只需要将 PageInfo 交给页面进行显示
//		// 封装了详细的信息
//		// 第二个参数用来配置需要连续显示的页数
//		PageInfo<Employee> pageInfo = new PageInfo<Employee>(employees, 5); 
//		model.addAttribute("pageInfo", pageInfo);
//		
//		return "list";
//	}
	
	/**
	 *	使用 @ResponseBody 注解可以将方法返回数据以 json 形式保存，需要导入Jackson 包
	 */
	@RequestMapping("/emps")
	@ResponseBody
	public Msg getEmpsWithJson(@RequestParam(value = "pageNum", defaultValue = "1") Integer pageNum) {
		PageHelper.startPage(pageNum, 5);
		List<Employee> employees = employeeService.getEmployees();
		// 使用 PageInfo 包装查询结果，只需要将 PageInfo 交给页面进行显示
		// 封装了详细的信息
		// 第二个参数用来配置需要连续显示的页数
		PageInfo<Employee> pageInfo = new PageInfo<Employee>(employees, 5); 
		
		return Msg.success().add("pageInfo", pageInfo);
	}
	
	/**
	 * 通过员工 id 查询员工信息，返回数据以 json 形式保存
	 */
	@RequestMapping(value = "/empById/{empId}", method = RequestMethod.GET)
	@ResponseBody
	public Msg getEmpByIdWithJson(@PathVariable(value = "empId") Integer empId) {
		Employee employee = employeeService.getEmployeeById(empId);
		return Msg.success().add("employee", employee);
	}
	
	/**
	 * 员工保存
	 * 加入 JSR303 校验：
	 * 	1、导入 Hibernate-Validator jar包依赖
	 * 	2、在 Employee 中使用 @Pattern 添加校验规则
	 * 	3、在传入的 employee 参数前添加 @Valid 注解，
	 * 		并传入 BindingResult 类型参数来封装校验结果
	 * 	4、使用 BindingResult 对象的 hasErrors() 方法判断是否校验成功
	 * @param employee
	 * @return
	 */
	@RequestMapping(value = "/addEmp", method = RequestMethod.POST)
	@ResponseBody
	public Msg addEmp(@Valid Employee employee, BindingResult result) {
		if(result.hasErrors()) {
			// 校验失败，应该返回失败，并在模态框中显示校验失败的错误信息
			Map<String, Object> map = new HashMap<String, Object>();
			List<FieldError> fieldErrors = result.getFieldErrors();
			for (FieldError fieldError : fieldErrors) {
				System.out.println("错误字段名：" + fieldError.getField() + "\n错误信息：" + fieldError.getDefaultMessage());
				map.put(fieldError.getField(), fieldError.getDefaultMessage());
			}
			return Msg.fail().add("errorFieldMap", map);
		} else {
			int addEmp = employeeService.addEmp(employee);
			if(addEmp == 0) {
				return Msg.fail();
			}
			return Msg.success();
		}
	}
	
	/**
	 * 检验员工名是否可用
	 */
	@RequestMapping("/checkEmpName")
	@ResponseBody
	public Msg checkEmpName(String empName) {
		// 先判断用户名是否是合法的表达式
		String empNameRegex = "(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5}$)";
		if( !empName.matches(empNameRegex) ) {
			return Msg.fail().add("va_msg", "员工名必须是2-5位中文，也可以是6-16位英文字母数字组合!");
		}
		// 数据库用户名重复校验
		boolean empNameCanUse = employeeService.checkEmpName(empName);
		//System.out.println(empNameCanUse);
		if (empNameCanUse) {
			return Msg.success();
		}
		return Msg.fail().add("va_msg", "用户名已存在！");
	}
	
	/**
	 * 检验邮箱名是否可用
	 */
	@RequestMapping("/checkEmail")
	@ResponseBody
	public Msg checkEmail(String email) {
		// 先判断邮箱是否是合法的表达式
		String emailRegex = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$";
		if( !email.matches(emailRegex) ) {
			return Msg.fail().add("va_msg", "邮箱格式不合法！例如：email1@163.com");
		}
		// 数据库邮箱重复校验
		boolean emailCanUse = employeeService.checkEmail(email);
		//System.out.println(empNameCanUse);
		if (emailCanUse) {
			return Msg.success();
		}
		return Msg.fail().add("va_msg", "邮箱已存在！");
	}
	
	/**
	 * 检验邮箱名是否可用（用于员工修改）
	 */
	@RequestMapping("/checkEmailWithId/{id}")
	@ResponseBody
	public Msg checkEmailWithId(String email, @PathVariable("id") Integer id) {
		// 先判断邮箱是否是合法的表达式
		String emailRegex = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$";
		if( !email.matches(emailRegex) ) {
			return Msg.fail().add("va_msg", "邮箱格式不合法！例如：email1@163.com");
		}
		// 数据库邮箱重复校验
		boolean emailCanUse = employeeService.checkEmail(email);
		//System.out.println(empNameCanUse);
		if (emailCanUse) {
			return Msg.success();
		}
		// 根据用户 id 查询用户，得到邮箱信息，与 email 进行比较
		// 如果当前邮箱与 id 匹配，则正确
		Employee employee = employeeService.getEmployeeById(id);
		if(employee != null && email.equals(employee.getEmail())) {
			return Msg.success();
		}
		return Msg.fail().add("va_msg", "邮箱已存在！");
	}
	
	/**
	 * 更新员工信息
	 */
	@RequestMapping(value = "/updateEmp/{empId}", method = RequestMethod.PUT)
	@ResponseBody
	public Msg updateEmp(@Valid Employee employee, BindingResult result) {
		if(result.hasErrors()) {
			// 校验失败，应该返回失败，并在模态框中显示校验失败的错误信息
			Map<String, Object> map = new HashMap<String, Object>();
			List<FieldError> fieldErrors = result.getFieldErrors();
			for (FieldError fieldError : fieldErrors) {
				System.out.println("错误字段名：" + fieldError.getField() + "\n错误信息：" + fieldError.getDefaultMessage());
				map.put(fieldError.getField(), fieldError.getDefaultMessage());
			}
			return Msg.fail().add("errorFieldMap", map);
		} else {
			System.out.println(employee);
			int updateEmp = employeeService.updateEmp(employee);
			System.out.println(updateEmp);
			if(updateEmp == 0) {
				return Msg.fail();
			}
			return Msg.success();
		}
	}
	
	// 删除指定编号的员工
	@RequestMapping(value = "/deleteEmpById/{empId}", method = RequestMethod.DELETE)
	@ResponseBody
	public Msg deleteEmpById(@PathVariable("empId") Integer empId) {
		int deleteEmpById = employeeService.deleteEmpById(empId);
		if(deleteEmpById == 0) {
			return Msg.fail();
		}
		return Msg.success();
	}
	
	// 批量删除员工
	// id: 1-2-3-4-5...
	@RequestMapping(value = "/deleteEmps/{empIds}", method = RequestMethod.DELETE)
	@ResponseBody
	public Msg batchDeleteEmps(@PathVariable("empIds") String idsStr) {
		long batchDeleteEmps = employeeService.batchDeleteEmps(idsStr);
		if(batchDeleteEmps == 0) {
			return Msg.fail();
		}
		return Msg.success();
	}
	
	/**
	 * 删除员工（二合一）
	 * 单个删除：1
	 * 多个删除：1-2-3...
	 */
	@RequestMapping(value = "/deleteEmp/{empIds}", method = RequestMethod.DELETE)
	@ResponseBody
	public Msg deleteEmp(@PathVariable("empIds") String empIds) {
		if(!empIds.contains("-")) {
			// 单个删除
			int empId = Integer.parseInt(empIds);
			int deleteEmpById = employeeService.deleteEmpById(empId);
			if(deleteEmpById == 0) {
				return Msg.fail();
			}
			return Msg.success();
		} else {
			// 批量删除
			String[] empIdArr = empIds.split("-");
			List<Integer> empIdList = new ArrayList<Integer>();
			for (int i = 0; i < empIdArr.length; i++) {
				empIdList.add(Integer.parseInt(empIdArr[i]));
			}
			int batchDeleteEmps = employeeService.batchDeleteEmps(empIdList);
			if(batchDeleteEmps == 0) {
				return Msg.fail();
			}
			return Msg.success();
		}
	}
}
