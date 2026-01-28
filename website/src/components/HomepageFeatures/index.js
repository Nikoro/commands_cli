import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Simple YAML Configuration',
    description: (
      <>
        Define your commands in a clean, human-readable <code>commands.yaml</code> file.
        No complex syntax to learn—just write your scripts and parameters in a
        format that&apos;s easy to read and maintain.
      </>
    ),
  },
  {
    title: 'Strong Type System',
    description: (
      <>
        Support for <strong>int</strong>, <strong>double</strong>, <strong>boolean</strong>, and <strong>enum</strong> types
        with built-in validation. Define required and optional parameters with
        defaults—your commands become self-documenting and robust.
      </>
    ),
  },
  {
    title: 'Interactive Pickers',
    description: (
      <>
        Enum parameters and switch commands automatically present beautiful
        interactive menus. No need to parse input manually or write custom
        prompts—it&apos;s all handled for you.
      </>
    ),
  },
];

function Feature({title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
