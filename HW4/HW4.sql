-- Homwework 4
select o.orderNumber,
priceEach,
quantityOrdered,
productName,
productLine,
city,
country,
orderDate
from orderdetails od
inner join orders o
on od.ordernumber = o.ordernumber
inner join products p
on od.productcode = p.productcode
inner join customers c
on o.customernumber = c.customernumber;