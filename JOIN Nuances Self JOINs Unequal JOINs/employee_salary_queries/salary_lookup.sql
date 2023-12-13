-- Select the first name, last name, salary and 
-- salary grade of employees whose salary fits between 
-- the lower_limit and upper_limit from the salgrade table.

SELECT first_name,last_name, salary, grade
FROM employee,salgrade
WHERE salary BETWEEN lower_limit AND upper_limit 


-- Show all benefits that the employee with id = 5 would receive. 
-- Select the first and last name of that employee, together with the benefits' names.


SELECT first_name,last_name,benefit_name
FROM employee,benefits
WHERE id=5 and salary>salary_req


-- For each benefit find the number of employees that receive them. 
-- Show two columns: the benefit_name and the count (name that column employee_count). 
-- Don't forget about benefits that aren't owned by anyone.

SELECT benefit_name, COUNT(e.id) AS employee_count
FROM benefits b
LEFT JOIN employee e
ON e.salary>=b.salary_req    # note that we can have an inequality for the 'ON' statement!
GROUP BY benefit_name