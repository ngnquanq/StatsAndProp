import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

class MultiClassDataDrawer:
    def __init__(self, n_classes=3):
        self.fig, self.ax = plt.subplots(figsize=(12, 8))
        self.ax.set_xlim(0, 10)
        self.ax.set_ylim(0, 10)
        self.ax.grid(True, alpha=0.3)
        
        self.n_classes = n_classes
        self.current_class = 0
        self.colors = ['blue', 'red', 'green', 'orange', 'purple', 'cyan', 'magenta', 'yellow']
        self.points = {i: [] for i in range(n_classes)}
        self.drawing = False
        
        self.update_title()
        
        # Connect events
        self.fig.canvas.mpl_connect('button_press_event', self.on_press)
        self.fig.canvas.mpl_connect('button_release_event', self.on_release)
        self.fig.canvas.mpl_connect('motion_notify_event', self.on_motion)
        self.fig.canvas.mpl_connect('key_press_event', self.on_key)
        
    def update_title(self):
        title = f'Drawing Class {self.current_class} ({self.colors[self.current_class]})\n'
        title += f'Press 0-{self.n_classes-1} to switch classes | Close window when done'
        self.ax.set_title(title, fontsize=12)
        self.fig.canvas.draw()
        
    def on_press(self, event):
        if event.inaxes:
            self.drawing = True
            
    def on_release(self, event):
        self.drawing = False
        
    def on_motion(self, event):
        if self.drawing and event.inaxes:
            self.points[self.current_class].append([event.xdata, event.ydata])
            color = self.colors[self.current_class]
            self.ax.plot(event.xdata, event.ydata, 'o', color=color, markersize=4)
            self.fig.canvas.draw_idle()
    
    def on_key(self, event):
        if event.key.isdigit():
            class_num = int(event.key)
            if 0 <= class_num < self.n_classes:
                self.current_class = class_num
                self.update_title()
                print(f"Switched to class {self.current_class}")
    
    def show(self):
        plt.show()
        return self.get_data()
    
    def get_data(self):
        """Returns data as numpy array with columns [x, y, class]"""
        all_data = []
        for class_id, pts in self.points.items():
            if len(pts) > 0:
                pts_array = np.array(pts)
                class_labels = np.full((len(pts), 1), class_id)
                all_data.append(np.hstack([pts_array, class_labels]))
        
        if all_data:
            return np.vstack(all_data)
        return np.array([])
    
    def save(self, filename='drawn_data.csv'):
        data = self.get_data()
        if len(data) > 0:
            df = pd.DataFrame(data, columns=['x', 'y', 'class'])
            df['class'] = df['class'].astype(int)
            df.to_csv(filename, index=False)
            
            # Print statistics
            print(f"\nSaved {len(data)} total points to {filename}")
            print("\nPoints per class:")
            for class_id in range(self.n_classes):
                count = len(self.points[class_id])
                if count > 0:
                    print(f"  Class {class_id}: {count} points")
            return data
        else:
            print("No data to save!")
            return np.array([])
    
    def plot_final(self):
        """Plot all classes with legend"""
        plt.figure(figsize=(10, 8))
        data = self.get_data()
        if len(data) > 0:
            for class_id in range(self.n_classes):
                class_data = data[data[:, 2] == class_id]
                if len(class_data) > 0:
                    plt.scatter(class_data[:, 0], class_data[:, 1], 
                              c=self.colors[class_id], label=f'Class {class_id}',
                              alpha=0.6, s=50)
            plt.xlim(0, 10)
            plt.ylim(0, 10)
            plt.grid(True, alpha=0.3)
            plt.legend()
            plt.title('Drawn Data Points')
            plt.xlabel('X')
            plt.ylabel('Y')
            plt.show()

# Usage Example
if __name__ == "__main__":
    # Create drawer with 3 classes (you can change this)
    drawer = MultiClassDataDrawer(n_classes=3)
    
    print("Instructions:")
    print("- Click and drag to draw points")
    print("- Press 0, 1, 2, etc. to switch between classes")
    print("- Close the window when done")
    print()
    
    # Draw data
    data = drawer.show()
    
    # Save to CSV
    drawer.save('multi_class_data.csv')
    
    # Show final plot with legend
    drawer.plot_final()
    
    # Print sample of data
    if len(data) > 0:
        print("\nFirst 10 points:")
        print(data[:10])