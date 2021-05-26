package com.ysw.crud.service;

import java.util.List;

import javax.validation.Valid;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ysw.crud.bean.Employee;
import com.ysw.crud.bean.EmployeeExample;
import com.ysw.crud.bean.EmployeeExample.Criteria;
import com.ysw.crud.dao.EmployeeMapper;

@Service
public class EmployeeService {
	
	@Autowired
	private EmployeeMapper employeeMapper;
	
	/**
	 * 处理批量操作的 SqlSession 会话
	 */
	@Autowired
	private SqlSession sqlSession;
	
	// 查询包含部门信息的所有员工信息
	public List<Employee> getEmployees() {
		// 按照员工编号排序
		EmployeeExample employeeExample = new EmployeeExample();
		// 注意：这里要写数据库中的列名
		employeeExample.setOrderByClause("emp_id");
		return employeeMapper.selectByExampleWithDept(employeeExample);
	}

	// 添加员工
	public int addEmp(Employee employee) {
		return employeeMapper.insertSelective(employee);
	}

	/**
	 * 检验员工名是否可用
	 * @param empName
	 * @return true:可用；false:不可用
	 */
	public boolean checkEmpName(String empName) {
		EmployeeExample example = new EmployeeExample();
		Criteria criteria = example.createCriteria();
		criteria.andEmpNameEqualTo(empName);
		long countByExample = employeeMapper.countByExample(example);
		
		return countByExample == 0;
	}

	public Employee getEmployeeById(Integer empId) {
		return employeeMapper.selectByPrimaryKey(empId);
	}

	public int updateEmp(Employee employee) {
		int updateByPrimaryKeySelective = employeeMapper.updateByPrimaryKeySelective(employee);
		return updateByPrimaryKeySelective;
	}

	public int deleteEmpById(Integer empId) {
		return employeeMapper.deleteByPrimaryKey(empId);
	}

	public long batchDeleteEmps(String idsStr) {
		// 获取批量删除的Mapper
		EmployeeMapper batchEmployeeMapper = sqlSession.getMapper(EmployeeMapper.class);
		String[] empIds = idsStr.split("-");
		long count = 0;
		for(int i = 0; i < empIds.length; i ++) {
			Integer empId = Integer.parseInt(empIds[i]);
			count += batchEmployeeMapper.deleteByPrimaryKey(empId);
		}
		return count;
	}
	
	public int batchDeleteEmps(List<Integer> empIds) {
		EmployeeExample employeeExample = new EmployeeExample();
		Criteria criteria = employeeExample.createCriteria();
		criteria.andEmpIdIn(empIds);
		int count = employeeMapper.deleteByExample(employeeExample);
		return count;
	}

	public boolean checkEmail(String email) {
		EmployeeExample example = new EmployeeExample();
		Criteria criteria = example.createCriteria();
		criteria.andEmailEqualTo(email);
		long countByExample = employeeMapper.countByExample(example);
		
		return countByExample == 0;
	}
}
