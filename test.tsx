import React from 'react';

interface Props {
  name: string;
  age: number;
}

const TestComponent: React.FC<Props> = ({ name, age }) => {
  const [count, setCount] = React.useState(0);
  
  const handleClick = () => {
    setCount(count + 1);
  };

  return (
    <div className="test-component">
      <h1>Hello {name}!</h1>
      <p>You are {age} years old.</p>
      <p>Count: {count}</p>
      <button onClick={handleClick}>Increment</button>
    </div>
  );
};

export default TestComponent;