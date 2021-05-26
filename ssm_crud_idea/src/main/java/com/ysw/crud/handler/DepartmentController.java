package com.ysw.crud.handler;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.ysw.crud.bean.Department;
import com.ysw.crud.bean.Msg;
import com.ysw.crud.service.DepartmentService;

@Controller
public class DepartmentController {
	
	@Autowired
	private DepartmentService departmentService;

	/**
	 * 返回所有的部门信息
	 * @return
	 */
	@RequestMapping("/depts")
	@ResponseBody
	public Msg getDepts() {
		List<Department> depts = departmentService.getDepts();
		return Msg.success().add("depts", depts);
	}
}
