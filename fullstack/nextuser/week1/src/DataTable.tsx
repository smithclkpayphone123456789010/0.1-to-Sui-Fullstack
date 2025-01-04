//import { faker } from '@faker-js/faker';
import {Profile} from './lib/contracts/Profile' 
// const generateFakeData = (count) => {
//   const data = [];
//   for (let i = 1; i <= count; i++) {
//     data.push({
//       id: i,
//       name: faker.person.fullName(),
//       description: faker.lorem.sentence(),
//     });
//   }
//   return data;
// };

export const DataTable = (props : {profiles:Profile[],ownerName:(val :string)=>string}) => {
  
  console.log("profiles:",props.profiles);
  return (
    <div className="p-4 ">
      <h1 className="text-2xl font-bold mb-4">数据表格</h1>
      <table className="min-w-full  border border-gray-300">
        <thead>
          <tr>

            <th className="py-2 px-4 border-b">Name</th>
            <th className="py-2 px-4 border-b">Description</th>
            <th className="py-2 px-4 border-b">Owner</th>
            <th className="py-2 px-4 border-b">ID</th>

          </tr>
        </thead>
        <tbody>
          {props.profiles.map((item) => (
            <tr key={item.id.id} className="hover:bg-gray-100">
              
              <td className="py-2 px-4 border-b">{item.name}</td>
              <td className="py-2 px-4 border-b">{item.description}</td>
              <td className="py-2 px-4 border-b">{props.ownerName(item.owner)}</td>
              <td className="py-2 px-4 border-b">{item.id.id}</td>

            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default DataTable;